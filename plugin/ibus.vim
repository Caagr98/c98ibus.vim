function! s:setInputMode(mode)
python << EOF
try:
	import ibus,dbus,vim
	bus = ibus.Bus()
	conn = bus.get_dbusconn().get_object(ibus.common.IBUS_SERVICE_IBUS, bus.current_input_contxt())
	ic = dbus.Interface(conn, dbus_interface=ibus.common.IBUS_IFACE_INPUT_CONTEXT)
	mode = vim.eval("a:mode")
	ic.PropertyActivate("InputMode." + mode, ibus.PROP_STATE_CHECKED)
except Exception, e:
	print "Failed to connect to iBus"
	print e
EOF
endfunction

function! s:disableIME()
	if s:normal() | call s:setInputMode('Direct') | endif
endfunction

function! s:enableIME()
	if s:normal() | call s:setInputMode('Hiragana') | endif
endfunction

function! s:normal()
	return index(['n', 'no', 'v', 'V', ''], mode()) >= 0
endfunction

augroup ibus
	au!
	au FocusGained * call s:disableIME()
	au FocusLost   * call s:enableIME()
	au InsertLeave * call s:disableIME()
	au InsertEnter * call s:enableIME()
	au VimEnter    * call s:disableIME()
	au VimLeave    * call s:enableIME()
augroup END
