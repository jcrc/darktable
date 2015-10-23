/*
    This file is part of darktable,
    copyright (c) 2014 tobias ellinghaus.

    darktable is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    darktable is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with darktable.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>
#include <CoreServices/CoreServices.h>
#include <AppKit/AppKit.h>
#include <gtk/gtk.h>
#include "osx.h"

void dt_osx_autoset_dpi(GtkWidget *widget)
{
    GdkScreen *screen = gtk_widget_get_screen(widget);
    if(screen == NULL) screen = gdk_screen_get_default();
    int monitor = gdk_screen_get_primary_monitor(screen);
    CGDirectDisplayID ids[monitor + 1];
    uint32_t total_ids;
    CGSize size_in_mm;
    GdkRectangle size_in_px;
    if(CGGetOnlineDisplayList(monitor + 1, &ids[0], &total_ids) == kCGErrorSuccess && total_ids == monitor + 1)
    {
      size_in_mm = CGDisplayScreenSize(ids[monitor]);
      gdk_screen_get_monitor_geometry(screen, monitor, &size_in_px);
      gdk_screen_set_resolution(
          screen, 25.4 * sqrt(size_in_px.width * size_in_px.width + size_in_px.height * size_in_px.height)
                  / sqrt(size_in_mm.width * size_in_mm.width + size_in_mm.height * size_in_mm.height));
    }
}

float dt_osx_get_ppd()
{
  NSScreen *nsscreen = [NSScreen mainScreen];
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
  if([nsscreen respondsToSelector: NSSelectorFromString(@"backingScaleFactor")]) {
    return [[nsscreen valueForKey: @"backingScaleFactor"] floatValue];
  } else {
    return [[nsscreen valueForKey: @"userSpaceScaleFactor"] floatValue];
  }
#else
  return [[nsscreen valueForKey: @"userSpaceScaleFactor"] floatValue];
#endif
}
