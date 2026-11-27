<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/ai-chatbot.css">
<div class="ai-chatbot" id="aiChatbot" data-chat-url="${pageContext.request.contextPath}/ai-chat">
    <button type="button" class="ai-chatbot-toggle" id="aiChatbotToggle" aria-label="Open Supplexio AI assistant" title="Supplexio AI Copilot">
        <i class="fas fa-robot"></i>
        <span class="ai-chatbot-pulse"></span>
    </button>

    <section class="ai-chatbot-panel" id="aiChatbotPanel" aria-label="Supplexio AI assistant" aria-hidden="true">
        <div class="ai-chatbot-header">
            <div class="ai-chatbot-brand">
                <div class="ai-chatbot-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div>
                    <strong>Supplexio AI <span class="ai-chatbot-live-dot"></span></strong>
                    <span>Platform &amp; Global Trade Copilot</span>
                </div>
            </div>
            <button type="button" id="aiChatbotClose" aria-label="Close assistant">
                <i class="fas fa-times"></i>
            </button>
        </div>

        <div class="ai-chatbot-messages" id="aiChatbotMessages">
            <div class="ai-chatbot-message bot">
                Hi! I'm <strong>Supplexio AI</strong>. Ask me how to launch reverse auctions, manage purchase orders, track low-stock alerts, or check Global Trade Intelligence.
            </div>
        </div>

        <div class="ai-chatbot-suggestions" id="aiChatbotSuggestions">
            <button type="button" class="ai-chip" data-prompt="How do I start a reverse auction?">Start an auction</button>
            <button type="button" class="ai-chip" data-prompt="Which items are currently low stock?">Low-stock status</button>
            <button type="button" class="ai-chip" data-prompt="How does the purchase order workflow work?">PO workflow</button>
        </div>

        <form class="ai-chatbot-form" id="aiChatbotForm">
            <input type="text" id="aiChatbotInput" maxlength="1200" autocomplete="off" placeholder="Ask anything about Supplexio...">
            <button type="submit" aria-label="Send question">
                <i class="fas fa-paper-plane"></i>
            </button>
        </form>
    </section>
</div>
<script src="${pageContext.request.contextPath}/assets/js/ai-chatbot.js"></script>
