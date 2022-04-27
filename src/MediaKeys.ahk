
;;; ! This code only runs on AuthoHotKey v2 ! ;;;
 
#SingleInstance
Persistent
tray := A_TrayMenu
tray.delete ; Remove default menu
tray.add "Pause / Resume", PauseMedia
tray.default := "Pause / Resume"
tray.add ; Separator
tray.add "Reload", ReloadScript
tray.add "Exit", ExitScript
tray.ClickCount := 1

Blinking := False
SetTimer SetIcon, -50


;;; Hotkeys ;;;

Pause::
{
   PauseMedia()
   KeyWait "Pause"
}

~ScrollLock::
{
   SetIcon()
}

#HotIf GetKeyState("ScrollLock", "T")

   Home::
   {
   SendInput "{Media_Prev}"
   KeyWait "Home"
   }

   End::
   {
   SendInput "{Media_Next}"
   KeyWait "End"
   }

   PgUp::
   {
   SendInput "{Volume_Up}"
   }

   PgDn::
   {
   SendInput "{Volume_Down}"
   }

#HotIf


;;; Functions ;;;

PauseMedia(*)
{
   SendInput "{Media_Play_Pause}"
   Blink()
}

ReloadScript(*)
{
   Reload
}

ExitScript(*)
{
   ExitApp
}

Blink(*)
{
   global Blinking

   Blinking := Not Blinking

   SetIcon()

   If Blinking ; Blink Once
      SetTimer Blink, -165
}

SetIcon(*)
{
   global Blinking

   If Blinking
      TraySetIcon("StatusIcons.dll", 3)

   Else If !GetKeyState("ScrollLock","T")
   {
      TraySetIcon("StatusIcons.dll", 2)
      A_IconTip := "Keys functioning normally."
   }

   Else
   {
      TraySetIcon("StatusIcons.dll", 1)
      A_IconTip := "Media Keys Activated!"
   }
}

/*  

   ; This is the version of the function to use when using Ahk2Exe to package the script.
   ; After turning the script into an executable, use Resource Hacker to add the 3 icons.

   SetIcon(*)
   {
      global Blinking

      If Blinking
         TraySetIcon(A_ScriptFullPath , 3)

      Else If !GetKeyState("ScrollLock","T")
      {
         TraySetIcon(A_ScriptFullPath, 2)
         A_IconTip := "Keys functioning normally."
      }

      Else
      {
         TraySetIcon(A_ScriptFullPath, 1)
         A_IconTip := "Media Keys Activated!"
      }
   }

   ; This is the old version of the function that uses individual icons instead of the dll.

   SetIcon(*)
   {
      global Blinking

      If Blinking
         TraySetIcon("Pressed.ico")

      Else If !GetKeyState("ScrollLock","T")
         TraySetIcon("Normal.ico")

      Else
         TraySetIcon("Media.ico")

      SplitPath A_IconFile ,,,, &KeyState
      A_IconTip := KeyState . "Keys Activated"
   }

*/




/*
   ; Code for a future attempt to use this script to connect / disconnect a bluetooth device, e.g. using the Insert key.
   ; https://www.autohotkey.com/boards/viewtopic.php?style=17&f=76&t=83224&sid=4e8b467539b5e1d136c1e1a43838788e&start=20

   ; Connect

      deviceName := "ATH-ANC500BT"

      DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
      VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
      NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
      NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint") ; fReturnAuthenticated
      VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
      NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")
      loop
      {
         If (A_Index = 1)
         {
            foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO)
            if !foundedDevice
            {
               msgbox "No bluetooth radios found"
               return
            }
         }
         else
         {
            if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO)
            {
               msgbox "Device not found"
               break
            }
         }
         if (StrGet(&BLUETOOTH_DEVICE_INFO+64) = deviceName)
         {
            VarSetCapacity(Handsfree, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree) ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
            VarSetCapacity(AudioSink, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)
            VarSetCapacity(GenAudServ, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001203-0000-1000-8000-00805F9B34FB}", "ptr", &GenAudServ)
            VarSetCapacity(HdstServ, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001108-0000-1000-8000-00805F9B34FB}", "ptr", &HdstServ)
            VarSetCapacity(AVRCTarget, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110C-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCTarget)
            VarSetCapacity(AVRC, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110E-0000-1000-8000-00805F9B34FB}", "ptr", &AVRC)
            VarSetCapacity(AVRCController, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110F-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCController)
            VarSetCapacity(PnP, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001200-0000-1000-8000-00805F9B34FB}", "ptr", &PnP)

            hr1 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", 0) ; voice
            hr2 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", 0) ; music
            ;hr3 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &GenAudServ, "int", 0) ; music
            hr4 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &HdstServ, "int", 0) ; music
            hr5 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCTarget, "int", 0) ; music
            hr6 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRC, "int", 0) ; music
            ;hr7 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCController, "int", 0) ; music
            ;hr8 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &PnP, "int", 0) ; music

            if (hr1 = 0) and (hr2 = 0) and (hr4 = 0) and (hr5 = 0) and (hr6 = 0){
               MsgBox, "Break"
               break
            }
         }
      }
      DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
      ExitApp

   ; Disconnect

      deviceName := "ATH-ANC500BT"

      DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
      VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
      NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
      NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint") ; fReturnAuthenticated
      VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
      NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")
      loop
      {
         If (A_Index = 1)
         {
            foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO)
            if !foundedDevice
            {
               msgbox "No bluetooth radios found"
               return
            }
         }
         else
         {
            if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO)
            {
               msgbox "Device not found"
               break
            }
         }
         if (StrGet(&BLUETOOTH_DEVICE_INFO+64) = deviceName)
         {
            VarSetCapacity(Handsfree, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree) ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
            VarSetCapacity(AudioSink, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)
            VarSetCapacity(GenAudServ, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001203-0000-1000-8000-00805F9B34FB}", "ptr", &GenAudServ)
            VarSetCapacity(HdstServ, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001108-0000-1000-8000-00805F9B34FB}", "ptr", &HdstServ)
            VarSetCapacity(AVRCTarget, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110C-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCTarget)
            VarSetCapacity(AVRC, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110E-0000-1000-8000-00805F9B34FB}", "ptr", &AVRC)
            VarSetCapacity(AVRCController, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{0000110F-0000-1000-8000-00805F9B34FB}", "ptr", &AVRCController)
            VarSetCapacity(PnP, 16)
            DllCall("ole32\CLSIDFromString", "wstr", "{00001200-0000-1000-8000-00805F9B34FB}", "ptr", &PnP)

            hr1 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", 1) ; voice
            hr2 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", 1) ; music
            ;hr3 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &GenAudServ, "int", 0) ; music
            hr4 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &HdstServ, "int", 1) ; music
            hr5 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCTarget, "int", 1) ; music
            hr6 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRC, "int", 1) ; music
            ;hr7 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AVRCController, "int", 0) ; music
            ;hr8 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &PnP, "int", 0) ; music

            if (hr1 = 0) and (hr2 = 0) and (hr4 = 0) and (hr5 = 0) and (hr6 = 0){
               break
            }
         }
      }
      DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
      ExitApp

*/