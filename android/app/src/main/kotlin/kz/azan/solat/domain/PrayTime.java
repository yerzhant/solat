package kz.azan.solat.domain;

//--------------------- Copyright Block ----------------------
/*

PrayTime.java: Prayer Times Calculator (ver 1.0)
Copyright (C) 2007-2010 PrayTimes.org

Java Code By: Hussain Ali Khan
Original JS Code By: Hamid Zarrabi-Zadeh

License: GNU LGPL v3.0

TERMS OF USE:
	Permission is granted to use this code, with or
	without modification, in any website or application
	provided that credit is given to the original work
	with a link back to PrayTimes.org.

This program is distributed in the hope that it will
be useful, but WITHOUT ANY WARRANTY.

PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.

*/

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Objects;

public class PrayTime {

    // ---------------------- Global Variables --------------------
    private int calcMethod; // calculation method
    private int asrJuristic; // Juristic method for Asr
    private int dhuhrMinutes; // minutes after mid-day for Dhuhr
    private int adjustHighLats; // adjusting method for higher latitudes
    private int timeFormat; // time format
    private double lat; // latitude
    private double lng; // longitude
    private double timeZone; // time-zone
    private double JDate; // Julian date
    // ------------------------------------------------------------
    // Calculation Methods
    private int Jafari; // Ithna Ashari
    private int Karachi; // University of Islamic Sciences, Karachi
    private int ISNA; // Islamic Society of North America (ISNA)
    private int MWL; // Muslim World League (MWL)
    private int Makkah; // Umm al-Qura, Makkah
    private int Egypt; // Egyptian General Authority of Survey
    private int Custom; // Custom Setting
    private int Tehran; // Institute of Geophysics, University of Tehran
    // Juristic Methods
    private int Shafii; // Shafii (standard)
    private int Hanafi; // Hanafi
    // Adjusting Methods for Higher Latitudes
    private int None; // No adjustment
    private int MidNight; // middle of night
    private int OneSeventh; // 1/7th of night
    private int AngleBased; // angle/60th of night
    private int Time12; // 12-hour format
    private int Time12NS; // 12-hour format with no suffix
    private int Floating; // floating point number
    // Time Names
    private final ArrayList<String> timeNames;
    private final String InvalidTime; // The string used for invalid times
    // --------------------- Technical Settings --------------------
    private int numIterations; // number of iterations needed to compute times
    // ------------------- Calc Method Parameters --------------------
    private final HashMap<Integer, double[]> methodParams;

    /*
     * this.methodParams[methodNum] = new Array(fa, ms, mv, is, iv);
     *
     * fa : fajr angle ms : maghrib selector (0 = angle; 1 = minutes after
     * sunset) mv : maghrib parameter value (in angle or minutes) is : isha
     * selector (0 = angle; 1 = minutes after maghrib) iv : isha parameter value
     * (in angle or minutes)
     */
    private final int[] offsets;

    public PrayTime() {
        // Initialize vars

        this.setCalcMethod(0);
        this.setAsrJuristic(0);
        this.setDhuhrMinutes(0);
        this.setAdjustHighLats(1);
        this.setTimeFormat(0);

        // Calculation Methods
        this.setJafari(); // Ithna Ashari
        this.setKarachi(); // University of Islamic Sciences, Karachi
        this.setISNA(); // Islamic Society of North America (ISNA)
        this.setMWL(); // Muslim World League (MWL)
        this.setMakkah(); // Umm al-Qura, Makkah
        this.setEgypt(); // Egyptian General Authority of Survey
        this.setTehran(); // Institute of Geophysics, University of Tehran
        this.setCustom(); // Custom Setting

        // Juristic Methods
        this.setShafii(); // Shafii (standard)
        this.setHanafi(); // Hanafi

        // Adjusting Methods for Higher Latitudes
        this.setNone(); // No adjustment
        this.setMidNight(); // middle of night
        this.setOneSeventh(); // 1/7th of night
        this.setAngleBased(); // angle/60th of night

        // Time Formats
        this.setTime24(); // 24-hour format
        this.setTime12(); // 12-hour format
        this.setTime12NS(); // 12-hour format with no suffix
        this.setFloating(); // floating point number

        // Time Names
        timeNames = new ArrayList<>();
        timeNames.add("Fajr");
        timeNames.add("Sunrise");
        timeNames.add("Dhuhr");
        timeNames.add("Asr");
        timeNames.add("Sunset");
        timeNames.add("Maghrib");
        timeNames.add("Isha");

        InvalidTime = "-----"; // The string used for invalid times

        // --------------------- Technical Settings --------------------

        this.setNumIterations(); // number of iterations needed to compute
        // times

        // ------------------- Calc Method Parameters --------------------

        // Tuning offsets {fajr, sunrise, dhuhr, asr, sunset, maghrib, isha}
        offsets = new int[7];
        offsets[0] = 0;
        offsets[1] = 0;
        offsets[2] = 0;
        offsets[3] = 0;
        offsets[4] = 0;
        offsets[5] = 0;
        offsets[6] = 0;

        /*
         *
         * fa : fajr angle ms : maghrib selector (0 = angle; 1 = minutes after
         * sunset) mv : maghrib parameter value (in angle or minutes) is : isha
         * selector (0 = angle; 1 = minutes after maghrib) iv : isha parameter
         * value (in angle or minutes)
         */
        methodParams = new HashMap<>();

        // Jafari
        double[] Jvalues = {16, 0, 4, 0, 14};
        methodParams.put(this.getJafari(), Jvalues);

        // Karachi
        double[] Kvalues = {18, 1, 0, 0, 18};
        methodParams.put(this.getKarachi(), Kvalues);

        // ISNA
        double[] Ivalues = {15, 1, 0, 0, 15};
        methodParams.put(this.getISNA(), Ivalues);

        // MWL
        double[] MWvalues = {18, 1, 0, 0, 17};
        methodParams.put(this.getMWL(), MWvalues);

        // Makkah
        double[] MKvalues = {18.5, 1, 0, 1, 90};
        methodParams.put(this.getMakkah(), MKvalues);

        // Egypt
        double[] Evalues = {19.5, 1, 0, 0, 17.5};
        methodParams.put(this.getEgypt(), Evalues);

        // Tehran
        double[] Tvalues = {17.7, 0, 4.5, 0, 14};
        methodParams.put(this.getTehran(), Tvalues);

        // Custom
        double[] Cvalues = {18, 1, 0, 0, 17};
        methodParams.put(this.getCustom(), Cvalues);

    }

    // ---------------------- Trigonometric Functions -----------------------
    // range reduce angle in degrees.
    private double fixAngle(double a) {
        a = a - (360 * (Math.floor(a / 360.0)));
        a = a < 0 ? (a + 360) : a;
        return a;
    }

    // range reduce hours to 0..23
    private double fixHour(double a) {
        a = a - 24.0 * Math.floor(a / 24.0);
        a = a < 0 ? (a + 24) : a;
        return a;
    }

    // radian to degree
    private double radiansToDegrees(double alpha) {
        return ((alpha * 180.0) / Math.PI);
    }

    // degree to radian
    private double DegreesToRadians(double alpha) {
        return ((alpha * Math.PI) / 180.0);
    }

    // degree sin
    private double dsin(double d) {
        return (Math.sin(DegreesToRadians(d)));
    }

    // degree cos
    private double dcos(double d) {
        return (Math.cos(DegreesToRadians(d)));
    }

    // degree tan
    private double dtan(double d) {
        return (Math.tan(DegreesToRadians(d)));
    }

    // degree arcsin
    private double darcsin(double x) {
        double val = Math.asin(x);
        return radiansToDegrees(val);
    }

    // degree arccos
    private double darccos(double x) {
        double val = Math.acos(x);
        return radiansToDegrees(val);
    }

    // degree arctan2
    private double darctan2(double y, double x) {
        double val = Math.atan2(y, x);
        return radiansToDegrees(val);
    }

    // degree arccot
    private double darccot(double x) {
        double val = Math.atan2(1.0, x);
        return radiansToDegrees(val);
    }

    // ---------------------- Julian Date Functions -----------------------
    // calculate julian date from a calendar date
    private double julianDate(int year, int month, int day) {

        if (month <= 2) {
            year -= 1;
            month += 12;
        }
        double A = Math.floor(year / 100.0);

        double B = 2 - A + Math.floor(A / 4.0);

        return Math.floor(365.25 * (year + 4716))
                + Math.floor(30.6001 * (month + 1)) + day + B - 1524.5;
    }

    // ---------------------- Calculation Functions -----------------------
    // References:
    // http://www.ummah.net/astronomy/saltime
    // http://aa.usno.navy.mil/faq/docs/SunApprox.html
    // compute declination angle of sun and equation of time
    private double[] sunPosition(double jd) {

        double D = jd - 2451545;
        double g = fixAngle(357.529 + 0.98560028 * D);
        double q = fixAngle(280.459 + 0.98564736 * D);
        double L = fixAngle(q + (1.915 * dsin(g)) + (0.020 * dsin(2 * g)));

        // double R = 1.00014 - 0.01671 * [self dcos:g] - 0.00014 * [self dcos:
        // (2*g)];
        double e = 23.439 - (0.00000036 * D);
        double d = darcsin(dsin(e) * dsin(L));
        double RA = (darctan2((dcos(e) * dsin(L)), (dcos(L)))) / 15.0;
        RA = fixHour(RA);
        double EqT = q / 15.0 - RA;
        double[] sPosition = new double[2];
        sPosition[0] = d;
        sPosition[1] = EqT;

        return sPosition;
    }

    // compute equation of time
    private double equationOfTime(double jd) {
        return sunPosition(jd)[1];
    }

    // compute declination angle of sun
    private double sunDeclination(double jd) {
        return sunPosition(jd)[0];
    }

    // compute mid-day (Dhuhr, Zawal) time
    private double computeMidDay(double t) {
        double T = equationOfTime(this.getJDate() + t);
        return fixHour(12 - T);
    }

    // compute time for a given angle G
    private double computeTime(double G, double t) {

        double D = sunDeclination(this.getJDate() + t);
        double Z = computeMidDay(t);
        double Beg = -dsin(G) - dsin(D) * dsin(this.getLat());
        double Mid = dcos(D) * dcos(this.getLat());
        double V = darccos(Beg / Mid) / 15.0;

        return Z + (G > 90 ? -V : V);
    }

    // compute the time of Asr
    // Shafii: step=1, Hanafi: step=2
    private double computeAsr(double step, double t) {
        double D = sunDeclination(this.getJDate() + t);
        double G = -darccot(step + dtan(Math.abs(this.getLat() - D)));
        return computeTime(G, t);
    }

    // ---------------------- Misc Functions -----------------------
    // compute the difference between two times
    private double timeDiff(double time1, double time2) {
        return fixHour(time2 - time1);
    }

    // -------------------- Interface Functions --------------------
    // return prayer times for a given date
    private ArrayList<String> getDatePrayerTimes(int year, int month, int day,
                                                 double latitude, double longitude, double tZone) {
        this.setLat(latitude);
        this.setLng(longitude);
        this.setTimeZone(tZone);
        this.setJDate(julianDate(year, month, day));
        double lonDiff = longitude / (15.0 * 24.0);
        this.setJDate(this.getJDate() - lonDiff);
        return computeDayTimes();
    }

    // return prayer times for a given date
    private ArrayList<String> getPrayerTimes(Calendar date, double latitude,
                                             double longitude, double tZone) {

        int year = date.get(Calendar.YEAR);
        int month = date.get(Calendar.MONTH);
        int day = date.get(Calendar.DATE);

        return getDatePrayerTimes(year, month + 1, day, latitude, longitude, tZone);
    }

    // convert double hours to 24h format
    public String floatToTime24(double time) {

        String result;

        if (Double.isNaN(time)) {
            return InvalidTime;
        }

        time = fixHour(time + 0.5 / 60.0); // add 0.5 minutes to round
        int hours = (int) Math.floor(time);
        double minutes = Math.floor((time - hours) * 60.0);

        if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
            result = "0" + hours + ":0" + Math.round(minutes);
        } else if ((hours >= 0 && hours <= 9)) {
            result = "0" + hours + ":" + Math.round(minutes);
        } else if ((minutes >= 0 && minutes <= 9)) {
            result = hours + ":0" + Math.round(minutes);
        } else {
            result = hours + ":" + Math.round(minutes);
        }
        return result;
    }

    // convert double hours to 12h format
    public String floatToTime12(double time, boolean noSuffix) {

        if (Double.isNaN(time)) {
            return InvalidTime;
        }

        time = fixHour(time + 0.5 / 60); // add 0.5 minutes to round
        int hours = (int) Math.floor(time);
        double minutes = Math.floor((time - hours) * 60);
        String suffix, result;
        if (hours >= 12) {
            suffix = "pm";
        } else {
            suffix = "am";
        }
        hours = ((((hours + 12) - 1) % (12)) + 1);
        /*hours = (hours + 12) - 1;
        int hrs = (int) hours % 12;
        hrs += 1;*/
        if (!noSuffix) {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0" + hours + ":0" + Math.round(minutes) + " "
                        + suffix;
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0" + hours + ":" + Math.round(minutes) + " " + suffix;
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = hours + ":0" + Math.round(minutes) + " " + suffix;
            } else {
                result = hours + ":" + Math.round(minutes) + " " + suffix;
            }

        } else {
            if ((hours >= 0 && hours <= 9) && (minutes >= 0 && minutes <= 9)) {
                result = "0" + hours + ":0" + Math.round(minutes);
            } else if ((hours >= 0 && hours <= 9)) {
                result = "0" + hours + ":" + Math.round(minutes);
            } else if ((minutes >= 0 && minutes <= 9)) {
                result = hours + ":0" + Math.round(minutes);
            } else {
                result = hours + ":" + Math.round(minutes);
            }
        }
        return result;

    }

    // ---------------------- Compute Prayer Times -----------------------
    // compute prayer times at given julian date
    private double[] computeTimes(double[] times) {

        double[] t = dayPortion(times);

        double Fajr = this.computeTime(
                180 - Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[0], t[0]);

        double Sunrise = this.computeTime(180 - 0.833, t[1]);

        double Dhuhr = this.computeMidDay(t[2]);
        double Asr = this.computeAsr(1 + this.getAsrJuristic(), t[3]);
        double Sunset = this.computeTime(0.833, t[4]);

        double Maghrib = this.computeTime(
                Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[2], t[5]);
        double Isha = this.computeTime(
                Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[4], t[6]);

        return new double[]{Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha};

    }

    // compute prayer times at given julian date
    private ArrayList<String> computeDayTimes() {
        double[] times = {5, 6, 12, 13, 18, 18, 18}; // default times

        for (int i = 1; i <= this.getNumIterations(); i++) {
            times = computeTimes(times);
        }

        adjustTimes(times);
        tuneTimes(times);

        return adjustTimesFormat(times);
    }

    // adjust times in a prayer time array
    private void adjustTimes(double[] times) {
        for (int i = 0; i < times.length; i++) {
            times[i] += this.getTimeZone() - this.getLng() / 15;
        }

        times[2] += this.getDhuhrMinutes() / 60.0; // Dhuhr
        if (Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[1] == 1) // Maghrib
        {
            times[5] = times[4] + Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[2] / 60;
        }
        if (Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[3] == 1) // Isha
        {
            times[6] = times[5] + Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[4] / 60;
        }

        if (this.getAdjustHighLats() != this.getNone()) {
            adjustHighLatTimes(times);
        }

    }

    // convert times array to given time format
    private ArrayList<String> adjustTimesFormat(double[] times) {

        ArrayList<String> result = new ArrayList<>();

        if (this.getTimeFormat() == this.getFloating()) {
            for (double time : times) {
                result.add(String.valueOf(time));
            }
            return result;
        }

        for (int i = 0; i < 7; i++) {
            if (this.getTimeFormat() == this.getTime12()) {
                result.add(floatToTime12(times[i], false));
            } else if (this.getTimeFormat() == this.getTime12NS()) {
                result.add(floatToTime12(times[i], true));
            } else {
                result.add(floatToTime24(times[i]));
            }
        }
        return result;
    }

    // adjust Fajr, Isha and Maghrib for locations in higher latitudes
    private void adjustHighLatTimes(double[] times) {
        double nightTime = timeDiff(times[4], times[1]); // sunset to sunrise

        // Adjust Fajr
        double FajrDiff = nightPortion(Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[0]) * nightTime;

        if (Double.isNaN(times[0]) || timeDiff(times[0], times[1]) > FajrDiff) {
            times[0] = times[1] - FajrDiff;
        }

        // Adjust Isha
        double IshaAngle = (Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[3] == 0) ? Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[4] : 18;
        double IshaDiff = this.nightPortion(IshaAngle) * nightTime;
        if (Double.isNaN(times[6]) || this.timeDiff(times[4], times[6]) > IshaDiff) {
            times[6] = times[4] + IshaDiff;
        }

        // Adjust Maghrib
        double MaghribAngle = (Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[1] == 0) ? Objects.requireNonNull(methodParams.get(this.getCalcMethod()))[2] : 4;
        double MaghribDiff = nightPortion(MaghribAngle) * nightTime;
        if (Double.isNaN(times[5]) || this.timeDiff(times[4], times[5]) > MaghribDiff) {
            times[5] = times[4] + MaghribDiff;
        }

    }

    // the night portion used for adjusting times in higher latitudes
    private double nightPortion(double angle) {
        double calc = 0;

        if (adjustHighLats == AngleBased)
            calc = (angle) / 60.0;
        else if (adjustHighLats == MidNight)
            calc = 0.5;
        else if (adjustHighLats == OneSeventh)
            calc = 0.14286;

        return calc;
    }

    // convert hours to day portions
    private double[] dayPortion(double[] times) {
        for (int i = 0; i < 7; i++) {
            times[i] /= 24;
        }
        return times;
    }

    // Tune timings for adjustments
    // Set time offsets
    public void tune(int[] offsetTimes) {

        // offsetTimes length
        // should be 7 in order
        // of Fajr, Sunrise,
        // Dhuhr, Asr, Sunset,
        // Maghrib, Isha
        System.arraycopy(offsetTimes, 0, this.offsets, 0, offsetTimes.length);
    }

    private void tuneTimes(double[] times) {
        for (int i = 0; i < times.length; i++) {
            times[i] = times[i] + this.offsets[i] / 60.0;
        }

    }

    public static void main(String[] args) {
        double latitude = -37.823689;
        double longitude = 145.121597;
        double timezone = 10;
        // Test Prayer times here
        PrayTime prayers = new PrayTime();

        prayers.setTimeFormat(prayers.Time12);
        prayers.setCalcMethod(prayers.Jafari);
        prayers.setAsrJuristic(prayers.Shafii);
        prayers.setAdjustHighLats(prayers.AngleBased);
        int[] offsets = {0, 0, 0, 0, 0, 0, 0}; // {Fajr,Sunrise,Dhuhr,Asr,Sunset,Maghrib,Isha}
        prayers.tune(offsets);

        Date now = new Date();
        Calendar cal = Calendar.getInstance();
        cal.setTime(now);

        ArrayList<String> prayerTimes = prayers.getPrayerTimes(cal,
                latitude, longitude, timezone);
        ArrayList<String> prayerNames = prayers.getTimeNames();

        for (int i = 0; i < prayerTimes.size(); i++) {
            System.out.println(prayerNames.get(i) + " - " + prayerTimes.get(i));
        }

    }

    public Times calculate(double latitude, double longitude, int timeZone) {
        PrayTime prayTime = new PrayTime();
        prayTime.setCalcMethod(prayTime.ISNA);
        prayTime.setAsrJuristic(prayTime.Hanafi);

        int[] offsets = {0, 0, 0, 0, 0, 0, 0};
        int correction = 5;
        if (latitude < 48) {
            correction = 3;
        }
        offsets[1] = -correction;
        offsets[2] = correction;
        offsets[3] = correction;
        offsets[5] = correction;
        prayTime.tune(offsets);

        Date now = new Date();
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(now);

        ArrayList<String> times = prayTime.getPrayerTimes(calendar,
                latitude, longitude, timeZone);

        return new Times(
                times.get(0),
                times.get(1),
                times.get(2),
                times.get(3),
                times.get(5),
                times.get(6)
        );
    }

    public int getCalcMethod() {
        return calcMethod;
    }

    public void setCalcMethod(int calcMethod) {
        this.calcMethod = calcMethod;
    }

    public int getAsrJuristic() {
        return asrJuristic;
    }

    public void setAsrJuristic(int asrJuristic) {
        this.asrJuristic = asrJuristic;
    }

    public int getDhuhrMinutes() {
        return dhuhrMinutes;
    }

    public void setDhuhrMinutes(int dhuhrMinutes) {
        this.dhuhrMinutes = dhuhrMinutes;
    }

    public int getAdjustHighLats() {
        return adjustHighLats;
    }

    public void setAdjustHighLats(int adjustHighLats) {
        this.adjustHighLats = adjustHighLats;
    }

    public int getTimeFormat() {
        return timeFormat;
    }

    public void setTimeFormat(int timeFormat) {
        this.timeFormat = timeFormat;
    }

    public double getLat() {
        return lat;
    }

    public void setLat(double lat) {
        this.lat = lat;
    }

    public double getLng() {
        return lng;
    }

    public void setLng(double lng) {
        this.lng = lng;
    }

    public double getTimeZone() {
        return timeZone;
    }

    public void setTimeZone(double timeZone) {
        this.timeZone = timeZone;
    }

    public double getJDate() {
        return JDate;
    }

    public void setJDate(double jDate) {
        JDate = jDate;
    }

    private int getJafari() {
        return Jafari;
    }

    private void setJafari() {
        Jafari = 0;
    }

    private int getKarachi() {
        return Karachi;
    }

    private void setKarachi() {
        Karachi = 1;
    }

    private int getISNA() {
        return ISNA;
    }

    private void setISNA() {
        ISNA = 2;
    }

    private int getMWL() {
        return MWL;
    }

    private void setMWL() {
        MWL = 3;
    }

    private int getMakkah() {
        return Makkah;
    }

    private void setMakkah() {
        Makkah = 4;
    }

    private int getEgypt() {
        return Egypt;
    }

    private void setEgypt() {
        Egypt = 5;
    }

    private int getCustom() {
        return Custom;
    }

    private void setCustom() {
        Custom = 7;
    }

    private int getTehran() {
        return Tehran;
    }

    private void setTehran() {
        Tehran = 6;
    }

    private void setShafii() {
        Shafii = 0;
    }

    private void setHanafi() {
        Hanafi = 1;
    }

    private int getNone() {
        return None;
    }

    private void setNone() {
        None = 0;
    }

    private void setMidNight() {
        MidNight = 1;
    }

    private void setOneSeventh() {
        OneSeventh = 2;
    }

    private void setAngleBased() {
        AngleBased = 3;
    }

    private void setTime24() {
    }

    private int getTime12() {
        return Time12;
    }

    private void setTime12() {
        Time12 = 1;
    }

    private int getTime12NS() {
        return Time12NS;
    }

    private void setTime12NS() {
        Time12NS = 2;
    }

    private int getFloating() {
        return Floating;
    }

    private void setFloating() {
        Floating = 3;
    }

    private int getNumIterations() {
        return numIterations;
    }

    private void setNumIterations() {
        this.numIterations = 1;
    }

    public ArrayList<String> getTimeNames() {
        return timeNames;
    }
}