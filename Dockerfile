FROM node:20.12.1-alpine AS base
# 1. Install dependencies only when needed
FROM base AS deps
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache libc6-compat
WORKDIR /usr/src/app
# COPY package.json package-lock.json ./
COPY package.json ./
#RUN npm config set registry http://registry.npmmirror.com
RUN npm config set registry http://nexus-cn.intranet.local/repository/npm-public/
RUN npm install

# 2. Rebuild the source code only when needed
FROM base AS builder
WORKDIR /usr/src/app
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY . .
RUN npm run build

# 3. Production image, copy all the files and run next
FROM base AS runner
WORKDIR /usr/src/app
ENV NODE_ENV=development

COPY --from=builder /usr/src/app/public ./public
COPY --from=builder /usr/src/app/.next ./.next

EXPOSE 3000
CMD ["node", "server.js"]
