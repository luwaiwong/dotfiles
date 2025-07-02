// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  // an expression can be broken across multiple lines using {}
  readonly property string time: {
    // The passed format string matches the default output of
    // the `date` command.
    Qt.formatDateTime(clock.date, "hh:mm:ss")
  }

  readonly property string date: {
    // The passed format string matches the default output of
    // the `date` command.
    Qt.formatDateTime(clock.date, "ddd MMMM d") + getDayWithSuffix(clock.date)
  }

  // This function will return the day of the month with its ordinal suffix
  function getDayWithSuffix(date) {
    const day = date.getDate(); // Get the day of the month (1-31)
    if (day > 3 && day < 21) return day + "th"; // Handles 11th, 12th, 13th
    switch (day % 10) {
      case 1:  return day + "st";
      case 2:  return day + "nd";
      case 3:  return day + "rd";
      default: return day + "th";
    }
  }
  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}