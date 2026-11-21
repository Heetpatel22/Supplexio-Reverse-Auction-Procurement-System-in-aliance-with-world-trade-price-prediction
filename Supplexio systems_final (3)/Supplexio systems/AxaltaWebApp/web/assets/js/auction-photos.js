(function () {
    /* ── Custom confirm modal (injected once) ─────────────────────────── */
    var _modal = null;

    function getModal() {
        if (_modal) { return _modal; }

        var overlay = document.createElement('div');
        overlay.className = 'ap-confirm-overlay';
        overlay.innerHTML =
            '<div class="ap-confirm-box">' +
                '<div class="ap-confirm-icon"><i class="fas fa-trash-alt"></i></div>' +
                '<h4 class="ap-confirm-title">Delete Photo?</h4>' +
                '<p class="ap-confirm-msg">This photo will be permanently removed and cannot be recovered.</p>' +
                '<div class="ap-confirm-actions">' +
                    '<button class="ap-confirm-cancel" id="apConfirmCancel">Cancel</button>' +
                    '<button class="ap-confirm-delete" id="apConfirmDelete"><i class="fas fa-trash"></i> Delete</button>' +
                '</div>' +
            '</div>';
        document.body.appendChild(overlay);

        // Close on backdrop click
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) { hideModal(); }
        });

        _modal = overlay;
        return _modal;
    }

    function showModal(onConfirm) {
        var modal = getModal();
        modal.classList.add('ap-confirm-visible');

        var cancelBtn = modal.querySelector('#apConfirmCancel');
        var deleteBtn = modal.querySelector('#apConfirmDelete');

        // Clone buttons to remove any previous listeners
        var newCancel = cancelBtn.cloneNode(true);
        var newDelete = deleteBtn.cloneNode(true);
        cancelBtn.parentNode.replaceChild(newCancel, cancelBtn);
        deleteBtn.parentNode.replaceChild(newDelete, deleteBtn);

        newCancel.addEventListener('click', hideModal);
        newDelete.addEventListener('click', function () {
            hideModal();
            onConfirm();
        });

        // Trap focus on cancel by default
        newCancel.focus();
    }

    function hideModal() {
        if (_modal) { _modal.classList.remove('ap-confirm-visible'); }
    }

    /* ── Gallery helpers ─────────────────────────────────────────────── */
    function isPreviewable(contentType, fileName) {
        var type = (contentType || '').toLowerCase();
        var name = (fileName || '').toLowerCase();
        if (type.indexOf('image/heic') === 0 || type.indexOf('image/heif') === 0) {
            return false;
        }
        if (name.endsWith('.heic') || name.endsWith('.heif')) {
            return false;
        }
        return type.indexOf('image/') === 0 || /\.(jpg|jpeg|png|gif|webp|bmp|svg)$/i.test(name);
    }

    function renderGallery(root, photos) {
        var gallery = root.querySelector('[data-photo-gallery]');
        var empty = root.querySelector('[data-photo-empty]');
        var viewBase = root.getAttribute('data-view-url');
        var deleteBase = root.getAttribute('data-delete-url');

        gallery.innerHTML = '';
        empty.style.display = photos.length ? 'none' : 'block';

        photos.forEach(function (photo) {
            var item = document.createElement('div');
            item.className = 'auction-photo-thumb';

            var link = document.createElement('a');
            link.href = viewBase + encodeURIComponent(photo.id);
            link.target = '_blank';
            link.rel = 'noopener';

            if (isPreviewable(photo.contentType, photo.fileName)) {
                var img = document.createElement('img');
                img.src = link.href;
                img.alt = photo.fileName || 'Auction product photo';
                link.appendChild(img);
            } else {
                var fallback = document.createElement('div');
                fallback.className = 'auction-photo-file-preview';
                fallback.innerHTML = '<i class="fas fa-file-image"></i>';
                link.appendChild(fallback);
            }

            var meta = document.createElement('div');
            meta.className = 'auction-photo-meta';
            meta.innerHTML = '<strong></strong><span></span>';
            meta.querySelector('strong').textContent = photo.fileName || 'Product photo';
            meta.querySelector('span').textContent = 'Added by ' + (photo.uploadedBy || 'USER');
            link.appendChild(meta);

            item.appendChild(link);

            // Delete button
            if (deleteBase && photo.canDelete) {
                var delBtn = document.createElement('button');
                delBtn.type = 'button';
                delBtn.className = 'auction-photo-delete-btn';
                delBtn.setAttribute('aria-label', 'Delete photo');
                delBtn.innerHTML = '<i class="fas fa-trash"></i>';

                delBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();

                    showModal(function () {
                        delBtn.disabled = true;
                        delBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

                        fetch(deleteBase + encodeURIComponent(photo.id), { method: 'POST' })
                            .then(function (res) { return res.json(); })
                            .then(function (data) {
                                if (data.ok) {
                                    loadPhotos(root);
                                } else {
                                    showErrorToast(data.error || 'Could not delete photo.');
                                    delBtn.disabled = false;
                                    delBtn.innerHTML = '<i class="fas fa-trash"></i>';
                                }
                            })
                            .catch(function () {
                                showErrorToast('Could not delete photo.');
                                delBtn.disabled = false;
                                delBtn.innerHTML = '<i class="fas fa-trash"></i>';
                            });
                    });
                });

                item.appendChild(delBtn);
            }

            gallery.appendChild(item);
        });
    }

    /* ── Small error toast (replaces alert()) ────────────────────────── */
    function showErrorToast(msg) {
        var toast = document.createElement('div');
        toast.className = 'ap-error-toast';
        toast.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + msg;
        document.body.appendChild(toast);
        setTimeout(function () { toast.classList.add('ap-toast-visible'); }, 10);
        setTimeout(function () {
            toast.classList.remove('ap-toast-visible');
            setTimeout(function () { document.body.removeChild(toast); }, 400);
        }, 3500);
    }

    function loadPhotos(root) {
        var listUrl = root.getAttribute('data-list-url') + encodeURIComponent(root.getAttribute('data-auction-id'));
        fetch(listUrl)
            .then(function (response) { return response.json(); })
            .then(function (photos) { renderGallery(root, photos || []); })
            .catch(function () {
                var empty = root.querySelector('[data-photo-empty]');
                empty.textContent = 'Could not load product photos.';
                empty.style.display = 'block';
            });
    }

    document.querySelectorAll('[data-auction-photo-widget]').forEach(function (root) {
        root.querySelectorAll('form').forEach(function (form) {
            form.addEventListener('submit', function (event) {
                var hasFile = Array.prototype.some.call(form.querySelectorAll('input[type="file"]'), function (input) {
                    return input.files && input.files.length;
                });
                if (!hasFile) {
                    event.preventDefault();
                }
            });
        });

        root.querySelectorAll('input[type="file"]').forEach(function (input) {
            input.addEventListener('change', function () {
                if (input.files && input.files.length) {
                    input.form.submit();
                }
            });
        });

        loadPhotos(root);
    });
})();
