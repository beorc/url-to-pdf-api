FROM node:10-alpine

ENV USER=pptruser
ENV UID=12345
ENV GID=23456

RUN addgroup --gid "$GID" "$USER" \
    && adduser \
    --disabled-password \
    --gecos "" \
    --home "/home/$USER" \
    --ingroup "$USER" \
    --uid "$UID" \
    "$USER"

RUN mkdir -p /home/$USER/Downloads \
      && chown -R $USER:$USER /home/$USER

RUN apk update && apk upgrade && \
      echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
      echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
      apk add --no-cache \
      chromium@edge \
      nss@edge \
      freetype@edge \
      harfbuzz@edge \
      ttf-freefont@edge
# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV CHROME_PATH /usr/bin/chromium-browser

# Run everything after as non-privileged user.
USER $USER
ENV HOST 0.0.0.0
WORKDIR /home/$USER
COPY package.json package-lock.json ./
RUN npm install
EXPOSE 9000
CMD [ "node", "src/index.js"]
