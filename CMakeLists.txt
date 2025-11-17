

cmake_minimum_required(VERSION 3.16)
project(baziqbrowser LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

# https://doc.qt.io/qt-6/appicon.html
set(DESKTOP_FILE baziqbrowser.desktop)
set(DESKTOP_FILE_TOR baziqbrowser_tor.desktop)
set(ICON_FILE baziqbrowser.svg)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 WebEngineQuick OPTIONAL_COMPONENTS Widgets)

qt_add_executable(baziqbrowser
    main.cpp
    utils.h
)

target_link_libraries(baziqbrowser PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
    Qt::QuickControls2
    Qt::WebEngineQuick
)

if(TARGET Qt6::Widgets)
    target_link_libraries(baziqbrowser PUBLIC
        Qt6::Widgets
    )
endif()

qt_add_qml_module(baziqbrowser
    URI BrowserUtils
    VERSION 1.0
    RESOURCE_PREFIX /
)

# Resources:
set(resources_resource_files
    "ApplicationRoot.qml"
    "BrowserDialog.qml"
    "BrowserWindow.qml"
    "DownloadView.qml"
    "FindBar.qml"
    "FullScreenNotification.qml"
    "HistoryView.qml"
    "BookmarkView.qml"
    "MostVisitedView.qml"
    "Database.js"
    "LModel.qml"
    "SettingsView.qml"
    "AdvancedSettingsView.qml"
)

qt_add_resources(baziqbrowser "resources"
    PREFIX
        "/"
    FILES
        ${resources_resource_files}
)

set(resources1_resource_files
    "icons/dialog-cancel.svg"
    "icons/dialog-ok-apply.svg"
    "icons/go-down.svg"
    "icons/go-next.svg"
    "icons/go-previous.svg"
    "icons/overflow-menu.svg"
    "icons/view-refresh.svg"
    "icons/list-add.svg"
    "icons/window-close.svg"
    "icons/bookmarks.svg"
    "icons/bookmarks-bookmarked.svg"
    "icons/bookmark-new.svg"
    "icons/bookmark-remove.svg"
    "icons/im-ban-kick-user.svg"
    "icons/edit-clear-history.svg"
    "icons/mobile-close-app.svg"
    "icons/edit-undo.svg"
    "icons/map-globe.svg"
    "icons/swap-panels.svg"
    "icons/page-simple.svg"
    "icons/zoom-in.svg"
    "icons/zoom-out.svg"
)

qt_add_resources(baziqbrowser "resources1"
    PREFIX
        "/icons"
    BASE
        "icons"
    FILES
        ${resources1_resource_files}
)

if(TARGET Qt::Widgets)
    target_link_libraries(baziqbrowser PUBLIC
        Qt::Widgets
    )
endif()

install(TARGETS baziqbrowser RUNTIME DESTINATION "/usr/bin")

install(FILES ${DESKTOP_FILE} DESTINATION "/usr/share/applications/")

install(FILES ${DESKTOP_FILE_TOR} DESTINATION "/usr/share/applications/")

install(FILES ${ICON_FILE} DESTINATION "/usr/share/icons/")
