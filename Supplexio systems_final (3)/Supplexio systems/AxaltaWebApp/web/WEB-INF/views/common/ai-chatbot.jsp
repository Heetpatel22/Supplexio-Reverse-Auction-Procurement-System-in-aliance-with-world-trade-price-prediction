<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ai-chatbot.css">
<div class="ai-chatbot" id="aiChatbot" data-chat-url="${pageContext.request.contextPath}/ai-chat">
    <button type="button" class="ai-chatbot-toggle" id="aiChatbotToggle" aria-label="Open Supplexio AI assistant">
        <i class="fas fa-robot"></i>
    </button>

    <section class="ai-chatbot-panel" id="aiChatbotPanel" aria-label="Supplexio AI assistant" aria-hidden="true">
        <div class="ai-chatbot-header">
            <div>
                <strong>Supplexio AI</strong>
                <span>Project guide</span>
            </div>
            <button type="button" id="aiChatbotClose" aria-label="Close assistant">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <div class="ai-chatbot-messages" id="aiChatbotMessages">
            <div class="ai-chatbot-message bot">
                Ask me how to create auctions, manage suppliers, track inventory, handle POs, or use any part of Supplexio.
            </div>
        </div>

        <form class="ai-chatbot-form" id="aiChatbotForm">
            <input type="text" id="aiChatbotInput" maxlength="1200" autocomplete="off" placeholder="Ask about Supplexio...">
            <button type="submit" aria-label="Send question">
                <i class="fas fa-paper-plane"></i>
            </button>
        </form>
    </section>
</div>
<script src="${pageContext.request.contextPath}/assets/js/ai-chatbot.js"></script>
