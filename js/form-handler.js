/**
 * Form Handler JavaScript
 * Brews of Opportunity Website
 * Handles all form submissions to the API
 */

class FormHandler {
    constructor() {
        // Use absolute URL to ensure correct protocol
        this.apiBase = window.location.origin + '/Brewss/api/submissions.php';
        this.init();
    }

    init() {
        // Initialize all forms
        this.initTrainingForm();
        this.initSponsorForm();
        this.initContactForm();
        this.initNewsletterForm();
    }

    // Training form handler
    initTrainingForm() {
        const form = document.getElementById('trainingForm');
        if (!form) return;

        form.addEventListener('submit', (e) => {
            e.preventDefault();

            if (!this.isFormValid(form)) return;

            const data = this.collectFormData(form);
            data.action = 'training';

            this.dispatchForm(form, data, 'Training registration submitted successfully!');
        });
    }

    // Sponsor form handler
    initSponsorForm() {
        const form = document.querySelector('.sponsor-form');
        if (!form) return;

        form.addEventListener('submit', (e) => {
            e.preventDefault();

            if (!this.isFormValid(form)) return;

            const data = this.collectFormData(form);
            data.action = 'sponsor';

            this.dispatchForm(form, data, 'Sponsor enquiry submitted successfully!');
        });
    }

    // Contact form handler
    initContactForm() {
        const form = document.querySelector('.contact-section form');
        if (!form) return;

        form.addEventListener('submit', (e) => {
            e.preventDefault();

            if (!this.isFormValid(form)) return;

            const data = this.collectFormData(form);
            data.action = 'contact';

            this.dispatchForm(form, data, 'Message sent successfully!');
        });
    }

    // Newsletter form handler
    initNewsletterForm() {
        const form = document.querySelector('#mc_embed_signup form');
        if (!form) return;

        form.addEventListener('submit', (e) => {
            e.preventDefault();

            if (!this.isFormValid(form)) return;

            const emailInput = form.querySelector('input[name="EMAIL"]');
            const email = emailInput ? emailInput.value.trim() : '';

            if (!email) {
                this.showError(form, 'Please enter your email address');
                return;
            }

            const data = {
                action: 'newsletter',
                email: email
            };

            this.dispatchForm(form, data, 'Successfully subscribed to newsletter!');
        });
    }

    // Generic form submission
    async submitForm(data) {
        if (!data.action) {
            throw new Error('No action specified for submission');
        }

        const formData = new FormData();
        Object.keys(data).forEach(key => {
            if (key !== 'action') {
                formData.append(key, data[key]);
            }
        });

        const url = `${this.apiBase}?action=${encodeURIComponent(data.action)}`;
        const response = await fetch(url, {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            const errorMessage = await this.extractErrorMessage(response);
            throw new Error(errorMessage);
        }

        const result = await this.parseJsonResponse(response);

        if (!result.success) {
            throw new Error(result.message || 'Submission failed');
        }

        return result;
    }

    async dispatchForm(form, data, successMessage) {
        this.setFormBusy(form, true);
        try {
            await this.submitForm(data);
            this.showSuccess(form, successMessage);
            form.reset();
        } catch (error) {
            this.showError(form, error.message);
        } finally {
            this.setFormBusy(form, false);
        }
    }

    isFormValid(form) {
        if (typeof form.checkValidity !== 'function') {
            return true;
        }

        const valid = form.checkValidity();
        if (!valid && typeof form.reportValidity === 'function') {
            form.reportValidity();
        }

        return valid;
    }

    collectFormData(form) {
        const data = {};
        const formData = new FormData(form);
        formData.forEach((value, key) => {
            data[key] = typeof value === 'string' ? value.trim() : value;
        });
        return data;
    }

    setFormBusy(form, isBusy) {
        const button = form.querySelector('button[type="submit"], input[type="submit"]');
        if (!button) return;
        button.disabled = isBusy;
        button.setAttribute('aria-busy', isBusy ? 'true' : 'false');
    }

    async extractErrorMessage(response) {
        const fallback = response.statusText || 'Submission failed';
        const contentType = (response.headers.get('content-type') || '').toLowerCase();

        if (contentType.includes('application/json')) {
            try {
                const payload = await response.json();
                return payload.message || fallback;
            } catch (error) {
                return fallback;
            }
        }

        try {
            const text = await response.text();
            return text || fallback;
        } catch (error) {
            return fallback;
        }
    }

    async parseJsonResponse(response) {
        try {
            return await response.json();
        } catch (error) {
            throw new Error('Server returned an invalid response.');
        }
    }

    // Show success message
    showSuccess(form, message) {
        this.removeMessages(form);

        const successDiv = document.createElement('div');
        successDiv.className = 'alert alert-success';
        successDiv.innerHTML = `
            <strong>Success!</strong> ${message}
        `;

        form.parentNode.insertBefore(successDiv, form);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (successDiv.parentNode) {
                successDiv.parentNode.removeChild(successDiv);
            }
        }, 5000);
    }

    // Show error message
    showError(form, message) {
        this.removeMessages(form);

        const errorDiv = document.createElement('div');
        errorDiv.className = 'alert alert-danger';
        errorDiv.innerHTML = `
            <strong>Error!</strong> ${message}
        `;

        form.parentNode.insertBefore(errorDiv, form);

        // Auto-remove after 10 seconds
        setTimeout(() => {
            if (errorDiv.parentNode) {
                errorDiv.parentNode.removeChild(errorDiv);
            }
        }, 10000);
    }

    // Remove existing messages
    removeMessages(form) {
        const alerts = form.parentNode.querySelectorAll('.alert');
        alerts.forEach(alert => alert.remove());
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new FormHandler();
});

// Export for potential use in other scripts
window.FormHandler = FormHandler;
