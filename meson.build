# openos-run — 独立 App (自包含, 可单独构建)
project('openos-run', 'cpp',
  version: 'DEV2026.1',
  default_options: ['cpp_std=c++17'])
qt6 = import('qt6')
qt6_dep = dependency('qt6', modules: ['Core', 'Gui', 'Qml', 'Quick'])
qt6_res = qt6.preprocess(qresources: 'qml.qrc', moc_headers: 'apps.h')
executable('openos-run',
  sources: ['main.cpp', 'apps.cpp', 'apps.h', qt6_res],
  dependencies: [qt6_dep],
  install: true)
