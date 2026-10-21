import QtQuick
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

NIconButtonHot {
    id: root

    property var pluginApi: null
    property ShellScreen screen

    readonly property var mainInstance: pluginApi?.mainInstance

    icon: "usb"
    tooltipText: mainInstance?.buildTooltip()

    onClicked: {
        if (mainInstance) {
            mainInstance.refreshDevices()
        }
        if (pluginApi?.openPanel) {
            pluginApi.openPanel(screen, root)
        }
    }

    onRightClicked: {
        PanelService.showContextMenu(contextMenu, root, screen)
    }

    NPopupContextMenu {
        id: contextMenu

        model: [
            {
                "label": pluginApi?.tr("context.open"),
                "action": "open-panel",
                "icon": "apps"
            },
            {
                "label": pluginApi?.tr("context.refresh"),
                "action": "refresh",
                "icon": "refresh"
            },
            {
                "label": pluginApi?.tr("context.unmount-all"),
                "action": "unmount-all",
                "icon": "plug-connected-x"
            },
            {
                "label": pluginApi?.tr("context.eject-all"),
                "action": "eject-all",
                "icon": "player-eject"
            },
            {
                "label": pluginApi?.tr("context.settings"),
                "action": "settings",
                "icon": "settings"
            }
        ]

        onTriggered: action => {
            contextMenu.close()
            PanelService.closeContextMenu(screen)

            if (action === "open-panel") {
                mainInstance?.refreshDevices()
                if (pluginApi?.openPanel) pluginApi.openPanel(screen, root)
            } else if (action === "refresh") {
                mainInstance?.refreshDevices()
            } else if (action === "unmount-all") {
                mainInstance?.unmountAll()
            } else if (action === "eject-all") {
                mainInstance?.ejectAll()
            } else if (action === "settings") {
                if (pluginApi?.manifest) {
                    BarService.openPluginSettings(screen, pluginApi.manifest)
                }
            }
        }
    }
}
