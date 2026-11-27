# dmgbuild settings: Badgertop install window with instructions in the background.
# Usage (release.sh does this): dmgbuild -s tools/dmg_settings.py -D app=dist/Badgertop.app -D bg=Resources/dmg-bg.tiff "Badgertop" out.dmg
import os.path
app = defines.get('app', 'dist/Badgertop.app')
readme = defines.get('readme', 'docs/FIRST-LAUNCH.txt')
files = [app, (readme, 'READ ME – first launch.txt')]
symlinks = {'Applications': '/Applications'}
icon_locations = {
    os.path.basename(app): (190, 196),
    'Applications': (530, 196),
    'READ ME – first launch.txt': (1100, 1100),   # mimo okno, kdo chce, najde
}
background = defines.get('bg', 'Resources/dmg-bg.tiff')
window_rect = ((180, 120), (720, 480))
default_view = 'icon-view'
show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False
show_icon_preview = False
icon_size = 96
text_size = 13
format = 'UDZO'
