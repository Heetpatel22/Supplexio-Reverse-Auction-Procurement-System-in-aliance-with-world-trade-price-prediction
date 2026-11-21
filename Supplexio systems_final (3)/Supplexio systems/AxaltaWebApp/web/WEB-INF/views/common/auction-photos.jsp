<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/auction-photos.css">
<div class="card auction-photo-card"
     data-auction-photo-widget
     data-auction-id="${auction.id}"
     data-list-url="${pageContext.request.contextPath}/auction-photos?auctionId="
     data-view-url="${pageContext.request.contextPath}/auction-photos?action=view&id="
     data-delete-url="${pageContext.request.contextPath}/auction-photos?action=delete&id=">
    <div class="card-header">
        <h4 class="mb-0"><i class="fas fa-images"></i> Product Photos</h4>
    </div>
    <div class="card-body">
        <form method="post"
              action="${pageContext.request.contextPath}/auction-photos"
              enctype="multipart/form-data"
              class="auction-photo-actions">
            <input type="hidden" name="auctionId" value="${auction.id}">

            <label class="auction-photo-action primary">
                <i class="fas fa-camera"></i> Click Photo
                <input type="file" name="photo" accept="image/*,.heic,.heif" capture="environment">
            </label>

            <label class="auction-photo-action">
                <i class="fas fa-mobile-alt"></i> Upload from Device
                <input type="file" name="photo" accept="image/*,.heic,.heif">
            </label>

            <label class="auction-photo-action">
                <i class="fas fa-folder-open"></i> Upload Files
                <input type="file" name="photo" accept="image/*,.heic,.heif,.jpg,.jpeg,.png,.gif,.webp,.bmp,.tif,.tiff,.svg">
            </label>
        </form>

        <p class="auction-photo-empty" data-photo-empty>No product photos uploaded yet.</p>
        <div class="auction-photo-gallery" data-photo-gallery></div>
    </div>
</div>
<script src="${pageContext.request.contextPath}/assets/js/auction-photos.js"></script>
