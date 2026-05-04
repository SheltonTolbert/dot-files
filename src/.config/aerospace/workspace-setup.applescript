-- Workspace bootstrap for AeroSpace (reset + idempotent)
-- NOTE: Requires Accessibility permissions for System Events.

on moveFocusedToWorkspace(ws)
  do shell script "aerospace move-node-to-workspace " & ws
end moveFocusedToWorkspace

on focusWindowId(winId)
  do shell script "aerospace focus --window-id " & winId
end focusWindowId

on newWindow(appName)
  tell application appName to activate
  delay 0.3
  tell application "System Events"
    keystroke "n" using {command down}
  end tell
  delay 0.3
end newWindow

on getPlan()
  set py to "" & ¬
"/usr/bin/python3 - <<'PY'\n" & ¬
"import json,sys\n" & ¬
"targets = [\n" & ¬
"  ('Slack','1',1),\n" & ¬
"  ('Arc','1',1),\n" & ¬
"  ('Ghostty','2',1),\n" & ¬
"  ('Ghostty','3',1),\n" & ¬
"  ('Arc','3',1),\n" & ¬
"  ('Arc','4',2),\n" & ¬
"]\n" & ¬
"def pick(d, keys):\n" & ¬
"  for k in keys:\n" & ¬
"    if k in d and d[k] not in (None, ''):\n" & ¬
"      return d[k]\n" & ¬
"  return None\n" & ¬
"try:\n" & ¬
"  data = json.load(sys.stdin)\n" & ¬
"except Exception:\n" & ¬
"  sys.exit(0)\n" & ¬
"windows = []\n" & ¬
"for w in data:\n" & ¬
"  app = pick(w, ['app-name','app_name','appName','app'])\n" & ¬
"  ws = pick(w, ['workspace','workspace-name','workspaceName','space','space-id','spaceId'])\n" & ¬
"  wid = pick(w, ['window-id','window_id','windowId','id'])\n" & ¬
"  if app is None or ws is None or wid is None:\n" & ¬
"    continue\n" & ¬
"  windows.append({'id': str(wid), 'app': str(app), 'ws': str(ws)})\n" & ¬
"assigned = set()\n" & ¬
"steps = []\n" & ¬
"def take_existing(app, ws, count):\n" & ¬
"  used = 0\n" & ¬
"  for w in windows:\n" & ¬
"    if used >= count: break\n" & ¬
"    if w['app']==app and w['ws']==ws and w['id'] not in assigned:\n" & ¬
"      assigned.add(w['id'])\n" & ¬
"      used += 1\n" & ¬
"  return used\n" & ¬
"for app, ws, count in targets:\n" & ¬
"  got = take_existing(app, ws, count)\n" & ¬
"  remaining = count - got\n" & ¬
"  if remaining > 0:\n" & ¬
"    for w in windows:\n" & ¬
"      if remaining <= 0: break\n" & ¬
"      if w['app']==app and w['ws']!=ws and w['id'] not in assigned:\n" & ¬
"        steps.append(('MOVE', w['id'], ws))\n" & ¬
"        assigned.add(w['id'])\n" & ¬
"        remaining -= 1\n" & ¬
"  if remaining > 0:\n" & ¬
"    for _ in range(remaining):\n" & ¬
"      steps.append(('NEW', app, ws))\n" & ¬
"# Move leftovers (any app) to workspace 5\n" & ¬
"for w in windows:\n" & ¬
"  if w['id'] not in assigned:\n" & ¬
"    steps.append(('MOVE', w['id'], '5'))\n" & ¬
"for s in steps:\n" & ¬
"  print('\\t'.join(s))\n" & ¬
"PY" & ""

  set cmd to "aerospace list-windows --all --json"
  set plan to do shell script cmd & " | " & py
  return plan
end getPlan

-- Ensure apps are running

do shell script "open -a 'Slack'"
do shell script "open -a 'Arc'"
do shell script "open -a 'Ghostty'"

delay 0.8

set plan to getPlan()
if plan is "" then return

set oldDelims to AppleScript's text item delimiters
set AppleScript's text item delimiters to linefeed
set linesList to text items of plan
set AppleScript's text item delimiters to oldDelims

repeat with lineText in linesList
  if lineText is "" then
    -- skip empty
  else
    set oldDelims to AppleScript's text item delimiters
    set AppleScript's text item delimiters to tab
    set parts to text items of lineText
    set AppleScript's text item delimiters to oldDelims
    if (count of parts) = 3 then
      set action to item 1 of parts
      set a to item 2 of parts
      set ws to item 3 of parts
      if action is "MOVE" then
        focusWindowId(a)
        delay 0.1
        moveFocusedToWorkspace(ws)
        delay 0.1
      else if action is "NEW" then
        newWindow(a)
        moveFocusedToWorkspace(ws)
        delay 0.1
      end if
    end if
  end if
end repeat
