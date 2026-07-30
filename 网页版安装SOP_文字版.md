# 爆款雷达 · 网页版安装 SOP(文字版)

点一个按钮复制模板,全程网页操作。
✋ 零终端 · 不用打任何指令 · 不用装任何软件。

装完之后系统每周自动:抓竞对 IG 爆款 → 转录口播 → AI 拆解 → 生成可拖拽管理的 dashboard。

---

## 开始前:准备 3 个账号(建议课前先建好)

- GitHub(github.com)— 免费,存代码 + 每周自动运行
- Supabase(supabase.com)— 免费,数据库。注册时选 Continue with GitHub 最快
- Apify(apify.com)— 唯一收费,约 $5/月,负责抓 IG

模板地址(老师会发给你):github.com/alvinokk/viral-radar-template

---

## 第 1 步:复制模板到你的账号(在 GitHub)

1. 打开老师发的模板地址
2. 点右上角绿色按钮「Use this template」→ Create a new repository
3. Repository name 填你想要的名字(例:my-viral-radar)
4. 选 Public → 点 Create repository

比喻:像复制一份 Notion 模板到自己账号——点一下就有。

---

## 第 2 步:建数据库,贴一段 SQL(在 Supabase)

1. supabase.com → New project(Region 选 Singapore,数据库密码自己存好)
2. 左边点 SQL Editor → New query
3. 把下面整段 SQL 复制,粘贴进去
4. 只改最底下 3 行的「这里换成竞对1/2/3」,换成你的竞对 IG 账号名(只要账号名,不要 @,不要链接;要几个加几行)。上面一个字都别动
5. 点 Run,看到 Success
6. 左边点 Table Editor,确认 posts 和 competitors 两张表都在,competitors 里是你填的竞对

```sql
-- 爆款雷达 · Supabase 建表(可重复跑,会先删旧表重建)

drop table if exists posts cascade;
drop table if exists competitors cascade;

-- 爆款帖子
create table posts (
  id              bigint generated always as identity primary key,
  post_id         text unique not null,
  tracker         text not null default 'IG',
  competitor      text,
  caption         text,
  transcript      text,
  ai_breakdown    text,
  post_type       text,
  likes           integer default 0,
  comments        integer default 0,
  followers       integer default 0,
  engagement_rate numeric generated always as
      ((likes + comments)::numeric / nullif(followers, 0)) stored,
  viral_score     numeric generated always as
      (round((greatest(likes,0) + comments*3)::numeric / nullif(followers,0) * 100, 2)) stored,
  post_date       date,
  post_url        text,
  thumbnail_url   text,
  video_url       text,
  hashtags        text,
  is_video        boolean default false,
  status          text default '未处理',
  last_synced     date,
  created_at      timestamptz default now()
);

create index posts_status_idx on posts (status);
create index posts_score_idx  on posts (viral_score desc);

-- 竞对名单
create table competitors (
  id         bigint generated always as identity primary key,
  username   text not null,
  tracker    text not null default 'IG',
  active     boolean default true,
  notes      text,
  created_at timestamptz default now()
);

-- ========= 安全锁(别删!公开钥匙只能读帖子 + 改 status 一列)=========
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

-- ↓↓↓ 只改这 3 行:换成你的竞对 IG 账号(纯账号名,不要 @,不要链接)↓↓↓
insert into competitors (username, tracker, active) values
  ('这里换成竞对1', 'IG', true),
  ('这里换成竞对2', 'IG', true),
  ('这里换成竞对3', 'IG', true);
```

⚠️ 只改最底下几行,上面一律别动:上面那一大段有安全锁,保证公开钥匙只能读数据、改状态,删不掉你的数据。删了或改了,别人拿到网址就能删光你的东西。

⚠️ 装好后别再重跑这段 SQL:开头有一句「先删表重建」,第一次装没事;但等抓到爆款之后再跑一次,会把数据清空。以后加/停竞对去 Table Editor 改,别回来重跑 SQL。

---

## 第 3 步:复制 3 把钥匙(在 Supabase)

Project Settings → API,复制三样(先放记事本):

- Project URL:https://xxxx.supabase.co
- anon public key:一长串
- service_role key:一长串(私密,下一步只进 Secrets)

⚠️⚠️ 最容易错的一步：Project URL 一定是 https://xxxx.supabase.co 这种。
不要复制你浏览器地址栏那个 supabase.com/dashboard/project/... —— 那是后台页面网址,填错了抓取会直接失败。

---

## 第 4 步:填钥匙和名字(在你的仓库)

你的仓库 → Settings → Secrets and variables → Actions。

① 点 Secrets 分页,New repository secret,加这 4 个(名字一模一样):

| Name | 值 |
|---|---|
| SUPABASE_URL | 第 3 步的 Project URL |
| SUPABASE_ANON_KEY | 第 3 步的 anon key |
| SUPABASE_SERVICE_ROLE_KEY | 第 3 步的 service_role key |
| APIFY_TOKEN | Apify → Settings → API 里的 token |

② 点 Variables 分页,New repository variable,加这 3 个:

| Name | 值(例) |
|---|---|
| BRAND | 系统名字,例:Yoga Radar |
| NICHE | 你的领域,例:瑜伽教练课程 |
| SYNC_DAY | 每周一 |

⚠️ 注意 SYNC_DAY：值要填「每周一」这种真的星期,别把名字 SYNC_DAY 又填进去,不然网页页脚会显示怪字。

放心贴：贴进网页输入框不会像终端那样贴烂——这是网页版最省心的地方。

---

## 第 5 步:开网页(Pages,在你的仓库)

你的仓库 → Settings → 左边 Pages：

- Source 选 Deploy from a branch
- Branch 选 main,文件夹选 /docs → 点 Save

现在 docs/ 还没生成没关系,先这样设着,跑完第 6 步网页就出来。

---

## 第 6 步:首次运行(在你的仓库)

1. 你的仓库 → Actions 分页,若有提示点「I understand my workflows, enable them」
2. 左边点 Sync Content → 右边 Run workflow → 绿色 Run workflow
3. 之后自动接力:转录 → AI 拆解 → 生成网页。首跑约 10-40 分钟,去忙别的
4. 跑完不用自己拼网址:去 **Settings → Pages**,顶部会显示「Your site is live at …」,点 **Visit site** 就打开你的 dashboard。加书签,以后每周开它。

检查三样:
- [ ] 网页打得开,有爆款卡片
- [ ] 点卡片能播放视频、看口播稿和 AI 拆解
- [ ] 拖一张卡到「拍摄中」,出现绿色 ✓(手机也能操作,不用密码)

比喻:电饭煲按下去就走开——网页好了自然在,不用盯着。

---

## 装好之后:每周只做三件事

1. 每周一打开网页,新爆款自动排好队,带口播稿和 AI 拆解
2. 想拍的拖到「拍摄中」,拍完拖「已处理」。团队打开都是同一个看板
3. 加/停竞对:Supabase → Table Editor → competitors 表加行(active 打勾)或取消勾

---

## 卡住了

| 现象 | 怎么办 |
|---|---|
| 网页 404 | 先等首跑完整结束;再看 Actions 有没有红色失败的 |
| 抓到 0 条 | competitors 表账号拼错 / active 没勾 |
| 标题还是「爆款雷达」 | Variables 的 BRAND 没设,设好后重跑 Deploy Dashboard |

---

## 三条红线

1. service_role key 只进 Secrets,不要贴别处或发群
2. 仓库是 Public,竞对数据和 AI 拆解任何人拿到链接都能看,介意就别用免费版
3. schema.sql 里的安全锁那段不要删

费用:只有 Apify ~$5/月,其余全免费。

有问题把截图发到学员群。
