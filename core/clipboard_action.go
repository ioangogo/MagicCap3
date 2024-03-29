// This code is a part of MagicCap which is a MPL-2.0 licensed project.
// Copyright (C) Jake Gealer <jake@gealer.email> 2019.

package core

import "github.com/magiccap/MagicCap/core/platform_specific"

// ClipboardAction handles the clipboard action.
func ClipboardAction(Data []byte, Extension string, URL *string) {
	Action, ok := ConfigItems["clipboard_action"].(float64)
	if !ok {
		Action = 1
	}
	switch Action {
	case 0:
		// Do nothing.
		return
	case 1:
		// Copy the file to the clipboard.
		platformspecific.BytesToClipboard(Data, Extension)
	case 2:
		// Copy the URL to the clipboard. If there is no URL, dump the bytes.
		if URL == nil {
			platformspecific.BytesToClipboard(Data, Extension)
		} else {
			platformspecific.StringToClipboard(*URL)
		}
	}
}
