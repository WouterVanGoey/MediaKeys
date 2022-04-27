
;;; ! This code only runs on AuthoHotKey v2 ! ;;;
 
#SingleInstance
Persistent

;;; *SET UP TRAY* ;;;

tray := A_TrayMenu
tray.delete ; Remove default menu
tray.add "Pause / Resume", PauseMedia
tray.default := "Pause / Resume"
tray.add ; Separator
tray.add "Always Pause", ToggleAlwaysPause
tray.Check("Always Pause")
tray.add ; Separator
tray.add "Reload", ReloadScript
tray.add "Exit", ExitScript
tray.ClickCount := 1

;;; *INITIALISE VARS* ;;;

AlwaysPause := True
Blinking := False

SetTimer SetIcon, -50

;;; *HOTKEYS DEFS* ;;;

~ScrollLock:: ; Update tray icon to reflect Scroll Lock state.
{
   SetIcon()
}

#HotIf AlwaysPause || GetKeyState("ScrollLock", "T")

   Pause::
   {
      PauseMedia()
      KeyWait "Pause"
   }

#HotIf

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

;;; *FUNCTION DEFS* ;;;

ToggleAlwaysPause(*)
{
    global AlwaysPause

    AlwaysPause := ! AlwaysPause
    tray.ToggleCheck("Always Pause")
}

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
   {
      TraySetIcon("StatusIcons.dll", 3) ; Blue = Pressed
   }

   Else If !GetKeyState("ScrollLock","T")
   {
      TraySetIcon("StatusIcons.dll", 2) ; Grey = Idle
      A_IconTip := "Keys functioning normally."
   }

   Else
   {
      TraySetIcon("StatusIcons.dll", 1) ; Green = Active
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
*/