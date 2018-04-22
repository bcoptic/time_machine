import 'dart:async';

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_calendars.dart';
import 'package:time_machine/time_machine_utilities.dart';

import 'package:test/test.dart';
import 'package:matcher/matcher.dart';
import 'package:time_machine/time_machine_timezones.dart';

import 'time_machine_testing.dart';

Future main() async {
  await runTests();
}

final CalendarSystem Iso = CalendarSystem.Iso;

@Test()
@TestCase(const [-9998])
@TestCase(const [9999])
void GetMonthsInYear_Valid(int year)
{
  TestHelper.AssertValid(Iso.GetMonthsInYear, year);
}

@Test()
@TestCase(const [-9999])
@TestCase(const [10000])
void GetMonthsInYear_Invalid(int year)
{
  TestHelper.AssertOutOfRange(Iso.GetMonthsInYear, year);
}

@Test()
@TestCase(const [-9998, 1])
@TestCase(const [9999, 12])
void GetDaysInMonth_Valid(int year, int month)
{
  TestHelper.AssertValid2(Iso.GetDaysInMonth, year, month);
}

@Test()
@TestCase(const [-9999, 1])
@TestCase(const [1, 0])
@TestCase(const [1, 13])
@TestCase(const [10000, 1])
void GetDaysInMonth_Invalid(int year, int month)
{
  TestHelper.AssertOutOfRange2(Iso.GetDaysInMonth, year, month);
}

@Test()
void GetDaysInMonth_Hebrew()
{
  TestHelper.AssertValid2(CalendarSystem.HebrewCivil.GetDaysInMonth, 5402, 13); // Leap year
  TestHelper.AssertOutOfRange2(CalendarSystem.HebrewCivil.GetDaysInMonth, 5401, 13); // Not a leap year
}

@Test()
@TestCase(const [-9998])
@TestCase(const [9999])
void IsLeapYear_Valid(int year)
{
  TestHelper.AssertValid(Iso.IsLeapYear, year);
}

@Test()
@TestCase(const [-9999])
@TestCase(const [10000])
void IsLeapYear_Invalid(int year)
{
  TestHelper.AssertOutOfRange(Iso.IsLeapYear, year);
}

@Test()
@TestCase(const [1])
@TestCase(const [9999])
void GetAbsoluteYear_ValidCe(int year)
{
  TestHelper.AssertValid2(Iso.GetAbsoluteYear, year, Era.Common);
}

@Test() 
@TestCase(const [1])
@TestCase(const [9999])
void GetAbsoluteYear_ValidBce(int year)
{
  TestHelper.AssertValid2(Iso.GetAbsoluteYear, year, Era.BeforeCommon);
}

@Test() 
@TestCase(const [0])
@TestCase(const [10000])
void GetAbsoluteYear_InvalidCe(int year)
{
  TestHelper.AssertOutOfRange2(Iso.GetAbsoluteYear, year, Era.Common);
}

@Test()
@TestCase(const [0])
@TestCase(const [10000])
void GetAbsoluteYear_InvalidBce(int year)
{
  TestHelper.AssertOutOfRange2(Iso.GetAbsoluteYear, year, Era.BeforeCommon);
}

@Test()
void GetAbsoluteYear_InvalidEra()
{
  TestHelper.AssertInvalid2(Iso.GetAbsoluteYear, 1, Era.AnnoPersico);
}

@Test()
void GetAbsoluteYear_NullEra()
{
  Era i = null;
  TestHelper.AssertArgumentNull2(Iso.GetAbsoluteYear, 1, i);
}

@Test()
void GetMinYearOfEra_NullEra()
{
  Era i = null;
  TestHelper.AssertArgumentNull(Iso.GetMinYearOfEra, i);
}

@Test()
void GetMinYearOfEra_InvalidEra()
{
  TestHelper.AssertInvalid(Iso.GetMinYearOfEra, Era.AnnoPersico);
}

@Test()
void GetMaxYearOfEra_NullEra()
{
  Era i = null;
  TestHelper.AssertArgumentNull(Iso.GetMaxYearOfEra, i);
}

@Test()
void GetMaxYearOfEra_InvalidEra()
{
  TestHelper.AssertInvalid(Iso.GetMaxYearOfEra, Era.AnnoPersico);
}