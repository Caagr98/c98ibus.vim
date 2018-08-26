function! s:setInputMode(mode)
python3 << EOF
try:
	import dbus, vim
	import ctypes
	dll = ctypes.CDLL("libibus-1.0.so")
	get_addr = dll.ibus_get_address
	get_addr.restype = ctypes.c_char_p

	dbusconn = dbus.connection.Connection(get_addr())
	ibus = dbus.Interface(dbusconn.get_object("org.freedesktop.IBus", "/org/freedesktop/IBus"), dbus_interface="org.freedesktop.IBus")
	ic = dbus.Interface(dbusconn.get_object("org.freedesktop.IBus", ibus.CurrentInputContext()), dbus_interface="org.freedesktop.IBus.InputContext")
	mode = vim.eval("a:mode")
	ic.PropertyActivate("InputMode." + mode, 1)
except Exception as e:
	print("Failed to connect to iBus")
	print(e)
EOF
endfunction

function! s:ime(ena)
	call s:setInputMode(a:ena == s:normal() ? 'Hiragana' : 'Direct')
endfunction

function! s:normal()
	return index(['n', 'no', 'v', 'V', ''], mode()) >= 0
endfunction

augroup ibus
	au!
	au FocusGained  * call s:ime(0) | au FocusLost    * call s:ime(1)
	au InsertLeave  * call s:ime(0) | au InsertEnter  * call s:ime(1)
	au VimEnter     * call s:ime(0) | au VimLeave     * call s:ime(1)
	au CmdlineEnter * call s:ime(0) | au CmdlineLeave * call s:ime(1)
	au CmdwinEnter  * call s:ime(0) | au CmdwinLeave  * call s:ime(1)
augroup END
