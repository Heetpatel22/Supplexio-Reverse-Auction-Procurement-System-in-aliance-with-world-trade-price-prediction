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
    var chatUrl = root.getAttribute('data-chat-url');

    function setOpen(isOpen) {
        root.classList.toggle('is-open', isOpen);
        panel.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
        if (isOpen) {
            input.focus();
        }
    }

    function addMessage(text, type) {
        var item = document.createElement('div');
        item.className = 'ai-chatbot-message ' + type;
        item.textContent = text;
        messages.appendChild(item);
        messages.scrollTop = messages.scrollHeight;
        return item;
    }

    function setLoading(isLoading) {
        form.classList.toggle('is-loading', isLoading);
        input.disabled = isLoading;
        form.querySelector('button').disabled = isLoading;
    }

    toggle.addEventListener('click', function () {
        setOpen(!root.classList.contains('is-open'));
    });

    closeButton.addEventListener('click', function () {
        setOpen(false);
    });

    form.addEventListener('submit', function (event) {
        event.preventDefault();

        var question = input.value.trim();
        if (!question) {
            return;
        }

        addMessage(question, 'user');
        input.value = '';
        setLoading(true);
        var pending = addMessage('Thinking...', 'bot');

        fetch(chatUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: question })
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
                pending.textContent = data.answer || 'I could not prepare an answer.';
            })
            .catch(function (error) {
                pending.textContent = error.message || 'I could not reach the assistant right now.';
            })
            .finally(function () {
                setLoading(false);
                input.focus();
            });
    });
})();
