// https://github.com/nodatime/nodatime/blob/master/src/NodaTime/Calendars/YearStartCacheEntry.cs
// 7208243  on Mar 18, 2015

import 'package:time_machine/time_machine.dart';

/// Type containing as much logic as possible for how the cache of "start of year" data works.
/// This is not specific to YearMonthDayCalculator - it can be used for
/// other frames of reference, so long as they comply with the restrictions listed below.
///
/// <remarks>
/// <para>
/// Each entry in the cache is a 32-bit number. The "value" part of the entry consists of the
/// number of days since the Unix epoch (negative for a value before the epoch). As Noda Time
/// only supports a number of ticks since the Unix epoch of between long.MinValue and long.MaxValue,
/// we only need to support a number of days in the range
/// [long.MinValue / TicksPerDay, long.MaxValue / TicksPerDay] which is [-10675200, 10675200] (rounding
/// away from 0). This value can be stored in 25 bits.
/// </para>
/// <para>
/// The remaining 7 bits of the value are used for validation. For any given year, the bottom
/// 10 bits are used as the index into the cache (which is an array). The next 7 most significant
/// bits are stored in the entry. So long as we have fewer than 17 significant bits in the year value,
/// this will be a unique combination. A single validation value (the most highly positive value) is
/// reserved to indicate an invalid entry. The cache is initialized with all entries invalid.
/// This gives us a range of year numbers greater than [-60000, 60000] without any risk of collisions. By
/// contrast, the ISO calendar years are in the range [-27255, 31195] - so we'd have to be dealing with a
/// calendar with either very short years, or an epoch a long way ahead or behind the Unix epoch.
/// </para>
/// <para>
/// The fact that each cache entry is only 32 bits means that we can safely use the cache from multiple
/// threads without locking. 32-bit aligned values are guaranteed to be accessed atomically, so we know we'll
/// never get the value for one year with the validation bits for another, for example.
/// </para>
/// </remarks>
@internal
class YearStartCacheEntry {
  static const int _cacheIndexBits = 10;
  static const int _cacheIndexMask = _cacheSize - 1;
  static const int _entryValidationBits = 7;
  static const int _entryValidationMask = (1 << _entryValidationBits) - 1;

  static const int _cacheSize = 1 << _cacheIndexBits;

  // Smallest (positive) year such that the validator is as high as possible.
  // (We shift the mask down by one because the top bit of the validator is effectively the sign bit for the
  // year, and so a validation value with all bits set is already used for e.g. year -1.)
  @internal
  static const int invalidEntryYear = (_entryValidationMask >> 1) << _cacheIndexBits;

  /// Entry which is guaranteed to be obviously invalid for any real date, by having
  /// a validation value which is larger than any valid year number.
  static final YearStartCacheEntry _invalid = new YearStartCacheEntry(invalidEntryYear, 0);

  /// Entry value: most significant 25 bits are the number of days (e.g. since the Unix epoch); remaining 7 bits are
  /// the validator.
  final int _value;

  YearStartCacheEntry(int year, int days) : _value = (days << _entryValidationBits) | _getValidator(year);

  @internal
  static List<YearStartCacheEntry> createCache() {
    List<YearStartCacheEntry> cache = new List<YearStartCacheEntry>(_cacheSize);
    for (int i = 0; i < cache.length; i++) {
      cache[i] = YearStartCacheEntry._invalid;
    }
    return cache;
  }

  /// Returns the validator to use for a given year, a non-negative number containing at most
  /// EntryValidationBits bits.
  static int _getValidator(int year) =>
      // Note that we assume that the input year fits into EntryValidationBits+CacheIndexBits bits - if not,
  // this would return the same validator for more than one input year, meaning that we could potentially
  // use the wrong cache value.
  // The masking here is necessary to remove some of the sign-extended high bits for negative years.
  (year >> _cacheIndexBits) & _entryValidationMask;

  /// Returns the cache index, in [0, CacheSize), that should be used to store the given year's cache entry.
  @internal
  static int getCacheIndex(int year) =>
      // Effectively keep only the bottom CacheIndexBits bits.
  year & _cacheIndexMask;

  /// Returns whether this cache entry is valid for the given year, and so is safe to use.  (We assume that we
  /// have located this entry via the correct cache index.)
  @internal
  bool isValidForYear(int year) => _getValidator(year) == (_value & _entryValidationMask);

  /// Returns the (signed) number of days since the Unix epoch for the cache entry.
  @internal
  int get startOfYearDays => _value >> _entryValidationBits;
}