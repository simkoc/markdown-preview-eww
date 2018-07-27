;;The MIT License (MIT)

;;Original Work Copyright (c) 2014, 2015, 2016 niku
;;Modified Work Copyright (c) 2018 Simon Koch

;;Permission is hereby granted, free of charge, to any person obtaining a copy of
;;this software and associated documentation files (the "Software"), to deal in
;;the Software without restriction, including without limitation the rights to
;;use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
;;the Software, and to permit persons to whom the Software is furnished to do so,
;;subject to the following conditions:

;;The above copyright notice and this permission notice shall be included in all
;;copies or substantial portions of the Software.

;;THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
;;FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
;;COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
;;IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;;CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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


(defun markdown-preview-do-convert ()
  (message "converting markdown to html")
  (let ((doc (buffer-substring-no-properties (point-min) (point-max)))
        (cb (current-buffer)))
    (process-send-string markdown-preview-eww-process-name (concat doc "\0"))))


(defun open-convert-tmp-file-in-eww ()
  (let ((cb (current-buffer)))
    (eww-open-file markdown-preview-eww-output-file-name)
    (switch-to-buffer cb)))


(defun initial-open-tmp-file-in-eww ()
  (let ((cb (current-buffer)))
    (split-window-horizontally)
    (message "well I am at least here a")
    (other-window 1)
    (message "well I am at least here b")
    (eww-open-file markdown-preview-eww-output-file-name)
    (other-window -1)))


(defun update-eww-buffer (ignore-a ignore-b ignore-c)
  (markdown-preview-do-convert)
  (open-convert-tmp-file-in-eww))


(defun start-background-ruby ()
  (let ((process-connection-type nil)
        (convert-command
	 (markdown-preview-eww-convert-command markdown-preview-eww-output-file-name)))
    (start-process markdown-preview-eww-process-name nil "ruby" "-e" convert-command)))


(defun stop-background-ruby ()
  (if (get-process markdown-preview-eww-process-name)
      (stop-process markdown-preview-eww-process-name)))



(defun markdown-live-eww-preview-mode ()
  "Major mode to live preview the markdown buffer in separate eww"
  (interactive)
  (setq major-mode 'markdown-live-eww-preview-mode)
  (setq mode-name  "markdown-live-eww-preview-mode")
  (stop-background-ruby)
  (start-background-ruby)
  (markdown-preview-do-convert) ;; do the initial convert
  (initial-open-tmp-file-in-eww)    ;; do the initial open in eww
  (add-hook 'after-change-functions 'update-eww-buffer t t)
  (run-hooks 'markdown-live-eww-preview-mode-hook))


(provide 'markdown-live-eww-preview-mode)
