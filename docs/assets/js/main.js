(() => {
    const toggle = document.querySelector('.menu-toggle');
    const navigation = document.querySelector('.site-navigation');

    if (toggle && navigation) {
        toggle.addEventListener('click', () => {
            const open = toggle.getAttribute('aria-expanded') === 'true';
            toggle.setAttribute('aria-expanded', String(!open));
            navigation.classList.toggle('is-open', !open);
        });

        window.addEventListener('resize', () => {
            if (window.innerWidth > 820) {
                toggle.setAttribute('aria-expanded', 'false');
                navigation.classList.remove('is-open');
            }
        });
    }

    const images = document.querySelectorAll('.gh-content .kg-image-card img, .gh-content .kg-gallery-card img');
    if (!images.length) return;

    const lightbox = document.createElement('div');
    lightbox.className = 'lightbox';
    lightbox.setAttribute('role', 'dialog');
    lightbox.setAttribute('aria-modal', 'true');
    lightbox.setAttribute('aria-label', document.documentElement.lang === 'de' ? 'Bildansicht' : 'Image viewer');
    lightbox.innerHTML = '<button class="lightbox-close" type="button" aria-label="Close">&times;</button><figure class="lightbox-figure"><img class="lightbox-image" alt=""><figcaption class="lightbox-caption"></figcaption></figure>';
    document.body.appendChild(lightbox);

    const lightboxImage = lightbox.querySelector('.lightbox-image');
    const caption = lightbox.querySelector('.lightbox-caption');
    const closeButton = lightbox.querySelector('.lightbox-close');
    let previousFocus = null;

    const close = () => {
        lightbox.classList.remove('is-open');
        document.body.classList.remove('lightbox-open');
        if (previousFocus) previousFocus.focus();
    };

    const open = (image) => {
        previousFocus = image;
        lightboxImage.src = image.currentSrc || image.src;
        lightboxImage.alt = image.alt || '';
        const figureCaption = image.closest('figure')?.querySelector('figcaption');
        caption.textContent = figureCaption?.textContent?.trim() || image.alt || '';
        caption.hidden = !caption.textContent;
        lightbox.classList.add('is-open');
        document.body.classList.add('lightbox-open');
        closeButton.setAttribute('aria-label', document.documentElement.lang === 'de' ? 'Bildansicht schließen' : 'Close image viewer');
        closeButton.focus();
    };

    images.forEach((image) => {
        image.tabIndex = 0;
        image.setAttribute('role', 'button');
        image.addEventListener('click', (event) => {
            event.preventDefault();
            open(image);
        });
        image.addEventListener('keydown', (event) => {
            if (event.key === 'Enter' || event.key === ' ') {
                event.preventDefault();
                open(image);
            }
        });
    });

    closeButton.addEventListener('click', close);
    lightbox.addEventListener('click', (event) => {
        if (event.target === lightbox) close();
    });
    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && lightbox.classList.contains('is-open')) close();
    });
})();
