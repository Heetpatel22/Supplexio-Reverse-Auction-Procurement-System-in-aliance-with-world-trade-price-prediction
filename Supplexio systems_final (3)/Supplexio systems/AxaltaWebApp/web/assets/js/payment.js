/**
 * Payment Management JavaScript
 * Handles functionality for payment list and statistics pages
 */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize date pickers with default values if needed
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    
    if (startDateInput && !startDateInput.value) {
        // Set default start date to first day of current month
        const today = new Date();
        const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
        startDateInput.valueAsDate = firstDay;
    }
    
    if (endDateInput && !endDateInput.value) {
        // Set default end date to today
        const today = new Date();
        endDateInput.valueAsDate = today;
    }
    
    // Add event listener for filter form submission
    const filterForm = document.querySelector('form[action*="/payment"]');
    if (filterForm) {
        filterForm.addEventListener('submit', function(event) {
            // Validate date range if both dates are provided
            if (startDateInput && endDateInput && 
                startDateInput.value && endDateInput.value) {
                const startDate = new Date(startDateInput.value);
                const endDate = new Date(endDateInput.value);
                
                if (startDate > endDate) {
                    event.preventDefault();
                    showPaymentNotice('Invalid date range', 'Start date cannot be after end date');
                    return false;
                }
            }
        });
    }
    
    // Highlight active sidebar item
    const sidebarItems = document.querySelectorAll('.sidebar-menu a');
    sidebarItems.forEach(item => {
        if (item.getAttribute('href').includes('/payment')) {
            item.classList.add('active');
        }
    });
});

function showPaymentNotice(title, message) {
    if (typeof $ === 'undefined' || typeof $.fn.modal === 'undefined') {
        return;
    }
    var modal = $('#paymentNoticeModal');
    if (!modal.length) {
        $('body').append(
            '<div class="modal fade" id="paymentNoticeModal" tabindex="-1" role="dialog" aria-hidden="true">' +
            '  <div class="modal-dialog modal-dialog-centered" role="document">' +
            '    <div class="modal-content">' +
            '      <div class="modal-header bg-warning text-dark">' +
            '        <h5 class="modal-title"><i class="fas fa-exclamation-triangle mr-2"></i><span data-payment-notice-title></span></h5>' +
            '        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
            '      </div>' +
            '      <div class="modal-body"><p class="mb-0" data-payment-notice-message></p></div>' +
            '      <div class="modal-footer"><button type="button" class="btn btn-warning" data-dismiss="modal">OK</button></div>' +
            '    </div>' +
            '  </div>' +
            '</div>'
        );
        modal = $('#paymentNoticeModal');
    }
    modal.find('[data-payment-notice-title]').text(title);
    modal.find('[data-payment-notice-message]').text(message);
    modal.modal('show');
}
