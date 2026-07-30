# 📡 爆款雷达 · 网页版(不用碰终端)

每周自动抓竞对 IG 爆款 → 转录口播 → AI 拆解 → 生成可拖拽管理的 dashboard。

**这个版本全程在网页上点鼠标就能装好,不用打任何指令。** 照下面 6 步走,约 20 分钟。

---

## 开始前:准备 3 个账号(建议课前先建好)

- **GitHub**(github.com)— 免费,存代码 + 每周自动运行
- **Supabase**(supabase.com)— 免费,数据库。注册时选 *Continue with GitHub* 最快
- **Apify**(apify.com)— 唯一收费,约 $5/月,负责抓 IG

---

## 第 1 步 · 复制这个模板到你的账号

1. 回到这个仓库最上面,点绿色按钮 **「Use this template」→「Create a new repository」**
2. Repository name 填你想要的名字(例:`my-viral-radar`)
3. 选 **Public**(免费版要公开才能出网页)
4. 点 **Create repository**

✅ 几秒钟你就有了一份自己的副本,全程鼠标,没碰终端。

---

## 第 2 步 · 建 Supabase 数据库

1. 到 supabase.com → **New project**(Region 选 Singapore,数据库密码自己存好)
2. 左边点 **SQL Editor** → New query
3. 打开你仓库里的 `schema.sql`,**整段复制**贴进去
4. 贴之前:把最底下的 `example_account_1/2/3` 换成**你要追踪的竞对 IG 账号名**(只要账号名,不要 @,不要链接;要几个加几行)
5. 点 **Run**,看到 Success
6. 左边点 **Table Editor**,确认 `posts` 和 `competitors` 两张表真的在,competitors 里是你的竞对

> ⚠️ 这段 SQL 里有安全锁——公开钥匙只能读数据、改状态,删不掉你的数据。**不要删减这段。**

---

## 第 3 步 · 复制 3 把 Supabase 钥匙

Supabase 左下角 **Project Settings → API**,复制三样(先放记事本):

| 名字 | 长这样 |
|---|---|
| Project URL | `https://xxxx.supabase.co` |
| `anon` `public` key | 一长串 |
| `service_role` key | 一长串(**私密**,只进下一步的 Secrets) |

---

## 第 4 步 · 在你的仓库填钥匙和名字(网页操作)

到**你的仓库** → **Settings** → 左边 **Secrets and variables** → **Actions**。

**先点 Secrets 分页,New repository secret,加这 4 个**(名字要一模一样):

| Secret 名字 | 值 |
|---|---|
| `SUPABASE_URL` | 第 3 步的 Project URL |
| `SUPABASE_ANON_KEY` | 第 3 步的 anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | 第 3 步的 service_role key |
| `APIFY_TOKEN` | Apify → Settings → API & Integrations 里的 token |

**再点 Variables 分页,New repository variable,加这 3 个:**

| Variable 名字 | 值(例) |
|---|---|
| `BRAND` | 你系统的名字,例:`Yoga Radar` |
| `NICHE` | 你的领域,例:`瑜伽教练课程`(决定 AI 拆解方向) |
| `SYNC_DAY` | 例:`每周一`(显示在网页页脚) |

> 贴进网页输入框不会像终端那样贴烂,放心贴。

---

## 第 5 步 · 开网页(GitHub Pages)

到**你的仓库** → **Settings** → 左边 **Pages**:

- Source 选 **Deploy from a branch**
- Branch 选 **main**,文件夹选 **/docs**,点 **Save**

（现在 `docs/` 还没生成,先这样设着,跑完第 6 步网页就会出来。）

---

## 第 6 步 · 首次运行

1. 到**你的仓库** → **Actions** 分页,如果看到提示就点 **「I understand my workflows, enable them」**
2. 左边点 **Sync Content** → 右边 **Run workflow** → 绿色 Run workflow
3. 等它跑完(几分钟)。之后会自动接力:转录 → AI 拆解 → 生成网页,整个首跑大约 **20-60 分钟**,去忙别的就好
4. 全部跑完后,打开你的网址:**`https://<你的用户名>.github.io/<仓库名>/`**

✅ 看到爆款卡片、能播放、能拖拽改状态 = 成功。手机也能开,改状态不用密码。

---

## 装好之后

- 📅 每周一自动更新(想改时间:编辑 `.github/workflows/sync.yml` 里的 cron 那行)
- ➕ 加/停竞对:Supabase → Table Editor → `competitors` 表加一行(active 打勾)或取消勾
- 🤖 系统每周自动推荐相关账号进 competitors(active 未勾),觉得好就勾
- 💰 费用:只有 Apify ~$5/月,其余全免费

## 卡住了

| 现象 | 怎么办 |
|---|---|
| 网页 404 | 先等首跑完整结束;再看 Actions 里有没有红色失败的 workflow |
| 抓到 0 条 | competitors 表竞对拼错 / active 没勾;Actions 的 Sync 日志看 below threshold |
| AI 拆解空 | GitHub Models 每日免费额度用完,隔天自动补 |
| 网页标题还是「爆款雷达」 | Variables 里的 `BRAND` 没设或拼错,设好后 Actions 里重跑 Deploy Dashboard |

## 三条红线

1. `service_role` key 只进 Secrets,不要贴到别处或发群里
2. 仓库是 Public——竞对数据和 AI 拆解任何人拿到链接都能看到,介意就别用免费版
3. `schema.sql` 里的安全锁那段不要删
