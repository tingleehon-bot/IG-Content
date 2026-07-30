-- ============================================================
-- 爆款雷达 · Supabase 建表(可重复跑,会先删旧表重建)
-- 在 Supabase → SQL Editor 整段粘贴 → Run,看到 Success 即可。
-- ============================================================

drop table if exists posts cascade;
drop table if exists competitors cascade;

-- ---------- 爆款帖子 ----------
create table posts (
  id              bigint generated always as identity primary key,
  post_id         text unique not null,
  tracker         text not null default 'IG',
  competitor      text,
  caption         text,
  transcript      text,                            -- 视频口播稿(自动转录)
  ai_breakdown    text,                            -- AI 拆解(自动生成)
  post_type       text,
  likes           integer default 0,
  comments        integer default 0,
  followers       integer default 0,
  engagement_rate numeric generated always as
      ((likes + comments)::numeric / nullif(followers, 0)) stored,
  viral_score     numeric generated always as
      (round((greatest(likes, 0) + comments * 3)::numeric / nullif(followers, 0) * 100, 2)) stored,
  post_date       date,
  post_url        text,
  thumbnail_url   text,
  video_url       text,
  hashtags        text,
  is_video        boolean default false,
  status          text default '未处理',            -- 未处理/拍摄中/已处理/跳过
  last_synced     date,
  created_at      timestamptz default now()
);

create index posts_status_idx on posts (status);
create index posts_score_idx  on posts (viral_score desc);

-- ---------- 竞对名单(自助管理:加行=追踪,取消active=停) ----------
create table competitors (
  id         bigint generated always as identity primary key,
  username   text not null,
  tracker    text not null default 'IG',
  active     boolean default true,
  notes      text,
  created_at timestamptz default now()
);

-- ============================================================
-- 安全锁(关键!):浏览器的公开 key 只能【读帖子】+【改 status 一列】。
-- 必须先 REVOKE ALL —— Supabase 默认给公开 key 全部权限,不撤掉的话
-- 任何拿到网址的人都能删光你的数据。
-- ============================================================
alter table posts       enable row level security;
alter table competitors enable row level security;

revoke all on posts       from anon;
revoke all on competitors from anon;

grant select on posts to anon;
grant update (status) on posts to anon;

drop policy if exists "anon read posts"    on posts;
drop policy if exists "anon update status" on posts;
create policy "anon read posts"    on posts for select to anon using (true);
create policy "anon update status" on posts for update to anon using (true) with check (true);

-- ============================================================
-- 竞对名单(把下面的示例换成你的竞对 IG 账号名,一行一个)
-- 只要账号名,不要 @,不要链接。改完整段一起 Run 就好。
-- 以后想加/停竞对:到 Table Editor 的 competitors 表加行或取消 active。
-- ============================================================
insert into competitors (username, tracker, active) values
  ('example_account_1', 'IG', true),
  ('example_account_2', 'IG', true),
  ('example_account_3', 'IG', true);
