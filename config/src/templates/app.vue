<template>
    <div>
        <Dialog ref="Dialog" :active="dialogOpen" style="margin: 0"></Dialog>
        <div v-if="!dialogOpen" class="columns is-gapless">
            <aside class="column aside" id="sidebar">
                <aside class="menu">
                    <ul class="menu-list">
                        <li>
                            <a
                                @click="toggleCoreModal('Captures')"
                                :data-tooltip="_('View all your previous captures')"
                                data-tooltip-position="right">
                                <i class="far fa-images"></i> {{ _('Capture History') }}</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('ClipboardAction')"
                                data-tooltip="Control what will be on your clipboard after capture"
                                data-tooltip-position="right">
                                <i class="far fa-clipboard"></i> {{ _('Clipboard Action') }}</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('FileConfig')"
                                data-tooltip="Configure capture file naming and local file saving"
                                data-tooltip-position="right">
                                    <i class="far fa-file-alt"></i> File Configuration</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('HotkeySettings')"
                                data-tooltip="Define hotkeys to trigger capture actions"
                                data-tooltip-position="right">
                                <i class="far fa-keyboard"></i> Hotkey Settings</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('UploaderConfig')"
                                data-tooltip="Enable uploading captures and configure the upload target"
                                data-tooltip-position="right">
                                <i class="fas fa-upload"></i> Uploader Settings</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('SelectorSettings')"
                                data-tooltip="Allows you to configure how the region selector behaves"
                                data-tooltip-position="right">
                                <i class="fas fa-pencil-ruler"></i> Selector Settings</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('AppSettings')"
                                data-tooltip="Change application settings and view information"
                                data-tooltip-position="right">
                                <i class="fas fa-cogs"></i> App Settings</a>
                        </li>

                        <li><hr/></li>

                        <li>
                            <a
                                @click="toggleCoreModal('Updates')"
                                data-tooltip="Check for updates and toggle receiving beta updates"
                                data-tooltip-position="right">
                                <i class="fas fa-cloud-download-alt"></i> Updates</a>
                        </li>
                        <li>
                            <a
                                @click="toggleTheme"
                                data-tooltip="Switch between light and dark mode"
                                data-tooltip-position="right">
                                <i class="fas fa-palette"></i> Toggle Theme</a>
                        </li>
                        <li>
                            <a
                                @click="toggleCoreModal('Docs')"
                                data-tooltip="Read the help documentation for the app"
                                data-tooltip-position="right">
                                    <i class="fas fa-book"></i> Help (Docs)</a>
                        </li>

                        <li><hr/></li>

                        <li>
                            <a
                                @click="runRemoteAction(0)"
                                data-tooltip="Shorten links using s.magiccap.me"
                                data-tooltip-position="right">
                                <i class="fas fa-link"></i> Link Shortener</a>
                        </li>
                        <li>
                            <a
                                @click="runRemoteAction(1)"
                                data-tooltip="Run the screen capture tool in MagicCap"
                                data-tooltip-position="right">
                                <i class="fas fa-camera"></i> Screen Capture</a>
                        </li>
                        <li>
                            <a
                                @click="runRemoteAction(2)"
                                data-tooltip="Capture a GIF recording of the screen"
                                data-tooltip-position="right">
                                <i class="fas fa-video"></i> GIF Capture</a>
                        </li>
                        <li>
                            <a
                                @click="runRemoteAction(3)"
                                data-tooltip="Capture the current image on your clipboard"
                                data-tooltip-position="right">
                                <i class="fas fa-clipboard-check"></i> Clipboard Capture</a>
                        </li>
                    </ul>
                </aside>
            </aside>
            <Captures ref="Captures"></Captures>
            <ClipboardAction ref="ClipboardAction"></ClipboardAction>
            <FileConfig ref="FileConfig"></FileConfig>
            <HotkeySettings ref="HotkeySettings"></HotkeySettings>
            <UploaderConfig ref="UploaderConfig" @appsettings-show="toggleCoreModal('AppSettings')"></UploaderConfig>
            <Debug ref="Debug"></Debug>
            <AppSettings ref="AppSettings" @debug-show="toggleCoreModal('Debug')" @open-dialog="openDialog"></AppSettings>
            <Updates ref="Updates"></Updates>
            <Docs ref="Docs"></Docs>
            <SelectorSettings ref="SelectorSettings"></SelectorSettings>
        </div>
    </div>
</template>
s
<script>
    import config from "../interfaces/config"
    import Captures from "./captures"
    import ClipboardAction from "./clipboard_action"
    import FileConfig from "./file_configuration"
    import HotkeySettings from "./hotkey_settings"
    import UploaderConfig from "./uploader_config"
    import AppSettings from "./app_settings"
    import Debug from "./debug"
    import Updates from "./updates"
    import Docs from "./docs"
    import SelectorSettings from "./selector_settings"
    import Dialog from "./dialog"
    import { getCaptures } from "../interfaces/captures"

    export default {
        name: "App",
        components: {
            Captures,
            ClipboardAction,
            FileConfig,
            HotkeySettings,
            UploaderConfig,
            AppSettings,
            Debug,
            Updates,
            Docs,
            SelectorSettings,
            Dialog,
        },
        data() {
            return {
                default: "Captures",
                dialogOpen: false,
            }
        },
        methods: {
            _(text) {
                return text
            },
            toggleCoreModal(name) {
                this.$refs[this.$data.default].toggle();
                this.$refs[name].toggle();
                this.$data.default = name
            },
            openDialog(title, description, buttons, cb) {
                const vm = this
                return new Promise(res => {
                    const dialog = vm.$refs.Dialog
                    dialog.$data.description = description
                    dialog.$data.title = title
                    dialog.$data.buttons = buttons
                    dialog.$data.resolver = res
                    vm.$data.dialogOpen = true
                }).then(async buttonId => {
                    vm.$data.dialogOpen = false
                    return buttonId
                }).then(buttonId => cb ? cb(buttonId) : buttonId).then(async r => {
                    // HACK: Fixes a bug where the captures would not update.
                    await vm.$nextTick()
                    await getCaptures()
                    vm.$refs.Captures.$forceUpdate()
                    return r
                })
            },
            toggleTheme() {
                config.o.light_theme = !config.o.light_theme
                config.save()
                fetch("/restart", {method: "GET"})
            },
            runRemoteAction(action) {
                if (action === 0) {
                    fetch("/call/ShowShort", {method: "GET"})
                } else if (action === 1) {
                    fetch("/call/RunScreenCapture", {method: "GET"})
                } else if (action === 2) {
                    fetch("/call/RunGIFCapture", {method: "GET"})
                } else if (action === 3) {
                    fetch("/call/RunClipboardCapture", {method: "GET"})
                }
            },
        },
    }
</script>
