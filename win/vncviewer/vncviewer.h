//  Copyright (C) 1999 AT&T Laboratories Cambridge. All Rights Reserved.
//  Copyright (C) 2005 Sun Microsystems, Inc. All Rights Reserved.
//  Copyright (C) 2012 D. R. Commander. All Rights Reserved.
//
//  This file is part of the VNC system.
//
//  The VNC system is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
//  USA.


#ifndef VNCVIEWER_H__
#define VNCVIEWER_H__

#pragma once

#include "res/resource.h"
#include "VNCviewerApp.h"
#include "Log.h"
#include "VNCHelp.h"
#include "HotKeys.h"

#define WM_SOCKEVENT WM_USER+1
#define WM_TRAYNOTIFY WM_SOCKEVENT+1
#define WM_REGIONUPDATED WM_TRAYNOTIFY+1
#define WM_FBUPDATERECVD WM_REGIONUPDATED+1
#define WM_SHUTDOWNLLKBHOOK WM_FBUPDATERECVD+1

// The enum is ordered in this way so as to maintain backward compatibility
// with TVNC 0.3.x
#define TVNC_SAMPOPT 4
enum {TVNC_1X=0, TVNC_4X, TVNC_2X, TVNC_GRAY};

#define TVNC_GRABOPT 3
enum {TVNC_FS=0, TVNC_ALWAYS, TVNC_MANUAL};

// The Application
extern VNCviewerApp *pApp;

// Global logger - may be used by anything
extern Log vnclog;
extern VNCHelp help;
extern HotKeys hotkeys;

// Display given window in centre of screen
void CentreWindow(HWND hwnd);

// Convert "host:display" into host and port
// Returns true if valid.
bool ParseDisplay(LPTSTR display, LPTSTR phost, int hostlen, int *port);
void FormatDisplay(int port, LPTSTR display, LPTSTR host);


// Macro DIALOG_MAKEINTRESOURCE is used to allow both normal windows dialogs
// and the selectable aspect ratio dialogs under WinCE (PalmPC vs HPC).
#ifndef UNDER_CE
#define DIALOG_MAKEINTRESOURCE MAKEINTRESOURCE
#else
// Under CE we pick dialog resource according to the 
// screen format selected or determined.
#define DIALOG_MAKEINTRESOURCE(res) SELECT_MAKEINTRESOURCE(res ## _PALM, res)
inline LPTSTR SELECT_MAKEINTRESOURCE(WORD res_palm, WORD res_hpc)
{
	if (pApp->m_options.m_palmpc)
		return MAKEINTRESOURCE(res_palm);
	else
		return MAKEINTRESOURCE(res_hpc);
}
#endif

// _snprintf() doesn't always terminate the string, so we use _snprintf_s()
// instead and define a macro that works like the Unix version.
#define snprintf(str, n, format, ...) \
	_snprintf_s(str, n, _TRUNCATE, format, __VA_ARGS__)

#endif // VNCVIEWER_H__

