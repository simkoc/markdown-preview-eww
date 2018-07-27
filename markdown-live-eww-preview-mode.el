(defvar markdown-live-eww-preview-mode-hook nil)

(defvar markdown-preview-eww-process-name "convert-from-md-to-html"
  "Process name of a converter.")

(defvar markdown-preview-eww-output-file-name "markdown-preview-eww-result.html"
  "Filename of converted html.")

(defvar markdown-preview-eww-waiting-idling-second 1
  "Seconds of convert waiting")

(defun markdown-preview-eww-convert-command (output-file-name)
  (format "require \"redcarpet\"

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
while doc = gets(\"\\0\")
  doc.chomp!(\"\\0\")
  File.write(\"%s\", markdown.render(doc))
end
" output-file-name))

(defun markdown-preview-eww-do-convert (start end)
  (let ((doc (buffer-substring-no-properties (point-min) (point-max)))
        (cb (current-buffer)))
    (process-send-string markdown-preview-eww-process-name (concat doc "\0"))
    (eww-open-file markdown-preview-eww-output-file-name)
    (switch-to-buffer cb)))

;;;### autoload
(defun markdown-preview-eww ()
  "Start a realtime markdown preview."
  (let ((process-connection-type nil)
        (convert-command (markdown-preview-eww-convert-command markdown-preview-eww-output-file-name)))
    (start-process markdown-preview-eww-process-name nil "ruby" "-e" convert-command)
    (run-with-idle-timer markdown-preview-eww-waiting-idling-second
			 nil
			 'markdown-preview-eww--do-convert)))


(defun start-background-ruby ()
  (let ((process-connection-type nil)
        (convert-command (markdown-preview-eww-convert-command markdown-preview-eww-output-file-name)))
    (start-process markdown-preview-eww-process-name nil "ruby" "-e" convert-command)))


(defun stop-brackground-ruby ()
  (stop-process markdown-preview-eww-process-name))


(defun markdown-live-eww-preview-mode ()
  "Major mode to live preview the markdown buffer in separate eww"
  (interactive)
  (message "I am run")
  (setq major-mode 'markdown-live-eww-preview-mode)
  (setq mode-name  "markdown-live-eww-preview-mode")
  (start-background-ruby)
  (add-hook 'after-change-functions 'markdown-preview-eww-do-convert t t)
  (run-hooks 'markdown-live-eww-preview-mode-hook))


(provide 'markdown-live-eww-preview-mode)
