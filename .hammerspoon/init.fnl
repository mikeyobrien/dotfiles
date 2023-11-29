(hs.ipc.cliInstall)
(require-macros :lib.macros)
;;(local secrets (require "secrets"))

(hs.console.darkMode true)
(hs.grid.setGrid :10x10)
(print hs.screen.allScreens)

(local lg-tv "LG TV SSCR2")
(local lg-ultrafine "LG UltraFine")
(local mini-screen :HS156KC)

(local bottom-right (hs.geometry.rect 0.4 0.3 0.6 0.7))
(local bottom-left (hs.geometry.rect 0 0.3 0.4 0.7))
(local top (hs.geometry.rect 0 0 1 0.3))
(local lg-layout [[:Arc nil mini-screen bottom-left nil nil]
                  [:Code nil lg-tv bottom-right nil nil]
                  [:iTerm2 nil lg-tv top nil nil]])

(local default-layout [[:Safari nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]
                       [:Emacs nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]
                       [:iTerm2 nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]
                       [:Firefox nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]
                       [:Code nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]
                       [:Arc nil (hs.screen.primaryScreen) hs.layout.maximized nil nil]])

(local expose (hs.expose.new nil {:showThumbnails false}))

(fn get-layout [screen]
  (let [screen-name (: screen :name)]
    (match screen-name
      lg-tv lg-layout
      _ default-layout)))

(fn fuzzy [choices func]
  (doto (hs.chooser.new func)
    (: :searchSubText true)
    (: :fgColor {:hex "#bbf"})
    (: :subTextColor {:hex "#aaa"})
    (: :width 25)
    (: :show)
    (: :choices choices)))

(fn select-window [window]
  (when window (window.window:focus)))

(fn show-window-fuzzy [app]
  (let [app-images {}
        focused-id (: (hs.window.focusedWindow) :id)
        windows (if (= app nil) (hs.window.visibleWindows)
                    (= app true) (: (hs.application.frontmostApplication) :allWindows)
                    (= (type app) "string") (: (hs.application.open app) :allWindows)
                    (app:allWindows))
        choices #(icollect [_ window (ipairs windows)]
                   (let [win-app (window:application)]
                     (if (= (. app-images win-app) nil) ; cache the app image per app
                         (tset app-images win-app (hs.image.imageFromAppBundle (win-app:bundleID))))
                     (let [text (window:title)
                           id (window:id)
                           active (= id focused-id)
                           subText (.. (win-app:title) (if active " (active)" ""))
                           image (. app-images win-app)
                           valid (= id focused-id)]
                       {: text : subText : image : valid : window})))]
    (fuzzy choices select-window)))


(hs.hotkey.bind hyper :f #(hs.application.launchOrFocus :Firefox))
(hs.hotkey.bind hyper :e #(hs.application.launchOrFocus :Emacs))
(hs.hotkey.bind hyper :i #(hs.application.launchOrFocusByBundleID "com.googlecode.iterm2"))


(hs.hotkey.bind hyper :D #(hs.alert.show (: (hs.screen.primaryScreen) :name)))
(hs.hotkey.bind hyper :G hs.grid.show)
(hs.hotkey.bind hyper :return #(expose:toggleShow))
(hs.hotkey.bind hyper hs.keycodes.map.space #(show-window-fuzzy))

(hs.hotkey.bind hyper :l #(hs.layout.apply (get-layout (hs.screen.primaryScreen))))

(hs.hotkey.bind [:ctrl :cmd] "`" nil
                (fn []
                  (if-let [console (hs.console.hswindow)]
                          (when (= console (hs.console.hswindow))
                            (hs.closeConsole))
                          (hs.openConsole))))

(fn move-windows-to-space-with-size [windows space size]
  (each [i v (ipairs windows)]
    (print (hs.spaces.moveWindowToSpace v space true))
    (hs.grid.set v size (hs.screen.primaryScreen))))

(fn organize-windows []
  (let [iterm-windows (: (hs.window.filter.new "iTerm2") :getWindows)
        arc-windows (: (hs.window.filter.new "Arc") :getWindows)
        vscode-windows (: (hs.window.filter.new "Code") :getWindows)
        primaryScreen (hs.screen.primaryScreen)
        spaces (hs.spaces.spacesForScreen primaryScreen)]
    ;; TODO: add offsets.
    (move-windows-to-space-with-size iterm-windows (. spaces 2) (hs.geometry.rect 0 0 5 1))
    (move-windows-to-space-with-size arc-windows (. spaces 2) (hs.geometry.rect 0 1 5 4))
    (move-windows-to-space-with-size vscode-windows (. spaces 2) (hs.geometry.rect 0 1 5 4))))


(hs.hotkey.bind ["cmd" "shift" "alt"] "A" organize-windows)