;;; org-bitly.el --- Integrate Bitly URL shortening into Org

;; Copyright (C) 2020  Erik L. Arneson <earneson@arnesonium.com>

;; Version: 1.0
;; Author: Erik L. Arneson <earneson@arnesonium.com>
;; URL: https://github.com/pymander/bitly-el
;; Package-Requires: '((emacs "27.1"))

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Integrate Bitly into Org Export.  This shortens URLs that are marked
;; with "bitly:" and optionally adds UTM parameters for later
;; analytics.

;;; Code:

(eval-when-compile
  (require 'cl-lib))
(require 'org-element)
(require 'bitly)

(defvar org-bitly-use-utm t
  "If T, create Urchin Tracking Module (UTM) parameters for URLs before shortening them with Bitly.")

(defun org-bitly-build-utm (&optional pos medium)
  "Build Urchin Tracking Module (UTM) parameters for the Org structure at POS.

MEDIUM Is the type of link, such as cost-per-click or email."
  (interactive "di")
  (unless pos
    (setq pos (point)))
  (let* ((utm-source (or (nth 0 (org-publish-get-project-from-filename (buffer-file-name (buffer-base-buffer)) t))
                         "org-mode"))
         (utm-medium (or medium 'document))
         (utm-name (or (org-entry-get pos "UTM_NAME")
                       (org-macro--find-keyword-value "UTM_NAME")
                       (org-macro--find-keyword-value "TITLE")))
         (base-query (format "utm-source=%s&utm-medium=%s"
                             (url-hexify-string utm-source)
                             utm-medium)))
    (if utm-name
        (concat base-query "&utm-name=" (url-hexify-string utm-name))
      base-query)))

(defun org-bitly-link-follow (path)
  "Function used for Bitly links to follow the link to PATH."
  (replace-regexp-in-string "^bitly:" "" path)
  (browse-url path))

(defun org-bitly-link-export (path desc format)
  "Use Bitly to shorten URLs on exporting from `org-mode'.

PATH is the path of the link, the text after the prefix (like \"http:\")
DESC is the description of the link, if any
FORMAT is the export format, a symbol like ‘html’ or ‘latex’ or ‘ascii’.

Currently this supports only HTML, Markdown, ODT, and LaTeX."
  (if (not desc)
      (setq desc path))
  (let* ((full-path (if org-bitly-use-utm
                        (concat path (if (string-match-p "\\?" path) "&" "?") (org-bitly-build-utm (point) format))
                      path))
         (short-url (bitly-shorten full-path)))
    (pcase format
      (`html (format "<a href=\"%s\">%s</a>" short-url desc))
      (`md (format "[%s](%s)" desc short-url))
      (`odt (format "<text:a xlink:type=\"simple\" xlink:href=\"%s\">%s</text:a>" short-url desc))
      (`latex (format "\\href{%s}{%s}" short-url desc))
      (`text (format "%s (%s)" desc short-url))
      (_ nil))))

(defvar org-bitly-links-defined nil)

;; We are only supporting Org 9 at this point.
(defun org-bitly-define-links ()
  "Set up the links for Bitly."
  (when (not org-bitly-links-defined)
      (setq org-bitly-links-defined t)
      (org-link-set-parameters "bitly"
                               :follow #'org-bitly-link-follow
                               :export #'org-bitly-link-export)))

(eval-after-load 'org-bitly
  (org-bitly-define-links))

(provide 'org-bitly)

;;; org-bitly.el ends here
