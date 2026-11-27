(function () {
    var root = document.getElementById('aiChatbot');
    if (!root || root.dataset.ready === 'true') {
        return;
    }
    root.dataset.ready = 'true';

    var toggle = document.getElementById('aiChatbotToggle');
    var panel = document.getElementById('aiChatbotPanel');
    var closeButton = document.getElementById('aiChatbotClose');
    var form = document.getElementById('aiChatbotForm');
    var input = document.getElementById('aiChatbotInput');
    var messages = document.getElementById('aiChatbotMessages');
    var suggestions = document.getElementById('aiChatbotSuggestions');
    var chatUrl = root.getAttribute('data-chat-url');

    function setOpen(isOpen) {
        root.classList.toggle('is-open', isOpen);
        panel.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
        if (isOpen) {
            input.focus();
        }
    }

    function escapeHtml(text) {
        return String(text || '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function formatBotReply(text) {
        var safe = escapeHtml(text);
        safe = safe.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
        safe = safe.replace(/`([^`]+)`/g, '<strong>$1</strong>');
        safe = safe.replace(/\n/g, '<br>');
        return safe;
    }

    function addMessage(text, type, asHtml) {
        var item = document.createElement('div');
        item.className = 'ai-chatbot-message ' + type;
        if (asHtml) {
            item.innerHTML = text;
        } else {
            item.textContent = text;
        }
        messages.appendChild(item);
        messages.scrollTop = messages.scrollHeight;
        return item;
    }

    function setLoading(isLoading) {
        form.classList.toggle('is-loading', isLoading);
        input.disabled = isLoading;
        form.querySelector('button').disabled = isLoading;
    }

    function sendQuestion(question) {
        if (!question) return;
        addMessage(question, 'user', false);
        input.value = '';
        setLoading(true);
        var pending = addMessage('Thinking...', 'bot', false);

        fetch(chatUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: question,
                page: window.location.pathname + window.location.search
            })
        })
        .then(function (response) {
            return response.json().then(function (data) {
                if (!response.ok) {
                    throw new Error(data.answer || 'Assistant request failed');
                }
                return data;
            });
        })
        .then(function (data) {
            pending.innerHTML = formatBotReply(data.answer || 'I could not prepare an answer.');
            messages.scrollTop = messages.scrollHeight;
        })
        .catch(function (error) {
            pending.textContent = error.message || 'I could not reach the assistant right now.';
        })
        .finally(function () {
            setLoading(false);
            input.focus();
        });
    }

    toggle.addEventListener('click', function () {
        setOpen(!root.classList.contains('is-open'));
    });

    closeButton.addEventListener('click', function () {
        setOpen(false);
    });

    if (suggestions) {
        suggestions.querySelectorAll('.ai-chip').forEach(function (chip) {
            chip.addEventListener('click', function () {
                sendQuestion(chip.getAttribute('data-prompt'));
            });
        });
    }

    form.addEventListener('submit', function (event) {
        event.preventDefault();
        sendQuestion(input.value.trim());
    });
})();
