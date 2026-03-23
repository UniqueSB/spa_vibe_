# Vibe Coding 대회 - Supabase 설정 가이드

## 1. Supabase 프로젝트 생성

1. https://supabase.com 접속
2. 새 프로젝트 생성
3. Project URL과 Anon Key 복사

## 2. 데이터베이스 테이블 생성

Supabase SQL Editor에서 아래 SQL을 실행하세요:

```sql
-- 프로젝트 좋아요 테이블
CREATE TABLE project_likes (
    id BIGSERIAL PRIMARY KEY,
    project_id TEXT UNIQUE NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 기기별 좋아요 기록 테이블 (중복 방지)
CREATE TABLE device_likes (
    id BIGSERIAL PRIMARY KEY,
    device_id TEXT NOT NULL,
    project_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(device_id, project_id)
);

-- 댓글 테이블
CREATE TABLE comments (
    id BIGSERIAL PRIMARY KEY,
    project_id TEXT NOT NULL,
    author TEXT NOT NULL,
    text TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_device_likes_device_id ON device_likes(device_id);
CREATE INDEX idx_device_likes_project_id ON device_likes(project_id);
CREATE INDEX idx_comments_project_id ON comments(project_id);

-- RLS (Row Level Security) 활성화
ALTER TABLE project_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽을 수 있도록 설정
CREATE POLICY "Public can read project_likes" ON project_likes
    FOR SELECT USING (true);

CREATE POLICY "Public can read device_likes" ON device_likes
    FOR SELECT USING (true);

CREATE POLICY "Public can read comments" ON comments
    FOR SELECT USING (true);

-- 모든 사용자가 쓸 수 있도록 설정
CREATE POLICY "Public can insert project_likes" ON project_likes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can update project_likes" ON project_likes
    FOR UPDATE USING (true);

CREATE POLICY "Public can insert device_likes" ON device_likes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can insert comments" ON comments
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Public can delete comments" ON comments
    FOR DELETE USING (true);
```

## ⚠️ 기존 테이블에 password 컬럼 추가 (이미 테이블을 생성한 경우)

이미 comments 테이블을 생성했다면, SQL Editor에서 다음 명령어를 실행하세요:

```sql
-- password 컬럼 추가 (없는 경우에만)
ALTER TABLE comments ADD COLUMN password TEXT;

-- 기존 정책이 있으면 먼저 삭제
DROP POLICY IF EXISTS "Public can delete comments" ON comments;

-- 삭제 정책 생성
CREATE POLICY "Public can delete comments" ON comments
    FOR DELETE USING (true);
```

## 3. 키를 코드에 하드코딩하지 않고 설정하기 (권장)

이 프로젝트는 `app.html`에 키를 직접 넣지 않습니다.
런타임에 `/api/config`에서 값을 읽어오도록 되어 있습니다.

### Vercel 환경변수 설정

Vercel Project Settings -> Environment Variables에 아래 2개를 추가하세요:

- `SUPABASE_URL` : 예) `https://xxxxx.supabase.co`
- `SUPABASE_ANON_KEY` : Supabase의 `anon` 공개 키

주의:
- `service_role` 키는 절대 넣지 마세요.
- `anon` 키는 공개 가능한 키이지만, 저장소 파일에는 하드코딩하지 않는 것을 권장합니다.

## 4. 로컬 서버 실행

PowerShell에서 아래 명령어로 로컬 서버를 실행합니다:

```powershell
# 간단한 HTTP 서버 실행 (Python 권장)
python -m http.server 8000

# 또는 Node.js를 사용하는 경우
npx http-server -p 8000
```

그 다음 브라우저에서 http://localhost:8000/app.html 접속

로컬 서버에서는 `/api/config`가 없으므로 자동으로 로컬 스토리지 모드로 실행됩니다.

## 5. Supabase 미설정 시

Supabase를 설정하지 않아도 로컬 스토리지로 작동합니다.
단, 다른 사용자와 데이터가 공유되지 않습니다.

## 테이블 구조 설명

### project_likes
- 각 프로젝트의 전체 좋아요 수 저장

### device_likes
- 기기별로 어떤 프로젝트에 좋아요를 눌렀는지 기록
- 중복 좋아요 방지

### comments
- 프로젝트별 댓글 저장
- 익명 닉네임과 함께 저장
