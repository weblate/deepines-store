from os.path import join, abspath, dirname

def get_res(res_name, dir='resources', ext='.svg'):
	return abspath(join(dirname(__file__), dir, res_name + ext))

def get_dl(uri, params=None, **kwargs):
	from requests import get
	try:
		return get(uri, params=params, **kwargs)
	except Exception as e:
		print(f"DL ERROR: {type(e).__name__}, URI: {uri}")
		class DummyResponse:
			status_code = None
			content = b""
			text = "" # FIXME: Use some kind of fallback for this, a text file maybe?
		return DummyResponse()

def tr(m, txt, disambiguation=None, n=-1):
	from PyQt5.QtCore import QCoreApplication
	return QCoreApplication.translate(m.__class__.__name__, txt, disambiguation, n)

def site():
	# FIXME: It copies the link, need to open browser instead.
	from PyQt5.QtWidgets import QApplication
	QApplication.clipboard().setText("https://deepinenespañol.org")

def set_blur(win):
	from os import system
	system('xprop -f _KDE_NET_WM_BLUR_BEHIND_REGION 32c -set _KDE_NET_WM_BLUR_BEHIND_REGION 0 -id {}'.format(int(win.winId())))

def write(b, to):
	open(to, 'wb').write(b.content) # wb should work with text and binary, keeps newlines