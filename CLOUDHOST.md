# 🚀 Securo - Free Cloud Hosting (Render + Supabase)

This repository is a fork optimized so you can host **Securo** in the cloud **100% for free**, without needing to clone the repository or configure a local Docker environment. You just need to connect this link directly to your Render dashboard.

When the application starts for the first time, the system itself will automatically run the database migrations and guide you through the initial setup (language, preferences, etc.).

---

## 📂 Files Changed / Added in this Fork

To enable free cloud hosting and resolve environment discrepancies, we modified the minimum number of files possible relative to the original project:

1. `backend/start.sh` *(Added)*: A lifecyle script that automates database infrastructure management. It automatically runs `alembic upgrade head` to build/update all tables on deploy before starting the Uvicorn server.
2. `frontend/default.conf.template` *(Modified)*: Reverted the local Docker DNS resolver (`127.0.0.11`) back to a direct `proxy_pass ${BACKEND_URL};` structure, ensuring Nginx can correctly resolve the public Render backend URL instead of looking for local Docker internal daemons.

---

## 📋 Prerequisites and Step-by-Step Guide

### 1. Get Pluggy Credentials (Open Finance)
Securo uses the Pluggy API to automatically fetch your banking data.

1. Go to the [Pluggy](https://pluggy.ai/) website and create a free account.
2. In their dashboard, create a **Development Application** (Sandbox/Development).
3. Save the generated **Client ID** and **Client Secret**. They will be used later in Render.

> 💡 **Note:** You do not need to configure any Webhook URL in the Pluggy dashboard. Securo uses an *Active Synchronization* model (the update button in the app UI fetches data actively on demand).

---

### 2. Configure the Database (Supabase)
Supabase will act as your cloud PostgreSQL server to store your transactions securely.

1. Create a free account on [Supabase](https://supabase.com/) and click to start a **New Project**.
2. ⚠️ **Crucial Password Step:** While filling out your project details, click on the **Generate a password** link under the *Database password* field. **Copy this generated password and save it in a secure file immediately**. You will strictly need it later to build your `DATABASE_URL` environment variable for Render.
3. 🌍 **Select Your Region:** On this same creation screen, make sure to choose the closest hosting **Region** to your target users (for example, *South America (São Paulo)* if you are in Brazil) or match it closely with your Render web service location to avoid network latency.
4. 🔗 **Get the Connection String (Session Pooler):** Once your project is fully provisioned and you are inside the main dashboard:
   * Go to **Project Settings** (gear icon) > **Database**.
   * Scroll down to the **Connection string** section.
   * Select the **Pooler** tab and set the Mode to **Session** (This prevents `Network is unreachable` errors on cloud environments like Render).
   * Copy the connection string provided.
   * ⚠️ **Important Formatting Notice:** This string will look like `postgresql://postgres.[your-project-id]:[YOUR-PASSWORD]@...`. Before pasting it into Render, you must:
     1. Replace `[YOUR-PASSWORD]` with the actual password you saved in **Step 2**.
     2. Add `+asyncpg` right after `postgresql` to match the application's required asynchronous driver format (transforming it into `postgresql+asyncpg://postgres...`).

---

### 3. Host the Frontend (Render)
We deploy the Frontend first to secure its public URL, which will be needed later.

1. On the Render Dashboard, click **New +** and select **Web Service**.
2. Connect your GitHub repository fork.
3. Configure the service with the following settings:
   * **Name:** `securo-frontend`
   * **Region:** (Choose the same region as your Supabase database)
   * **Branch:** `main` (or your preferred branch)
   * **Root Directory:** `frontend`
   * **Runtime:** `Docker`
   * **Instance Type:** `Free`
4. Click **Advanced** and add the following Environment Variable:
   * `BACKEND_URL`: (Leave this blank or put a placeholder for now. You will update this with the Backend URL once the backend is deployed in Step 5).
5. Click **Deploy Web Service**.

---

### 4. Deploy the Redis Instance (Render)
The backend requires a Redis instance for task queuing and caching. We will use Render's native, fully-managed Key Value service.

1. On the Render Dashboard, click **New +** and select **Key Value**.
2. Configure the service with the following settings:
   * **Name:** `securo-redis`
   * **Plan:** `Free`
3. Click **Create Key Value**.
4. Once provisioned, locate the **Connections** section on the dashboard and copy the **Internal Key Value URL**. *(It will look like `redis://red-xxxxxxxxxxxxxxxxxxxx:...`). This is the exact string you will paste into the `REDIS_URL` environment variable for the backend in the next step.*

---

### 5. Host the Backend (Render)
Now we deploy the core engine of the application, connecting it to our cloud Database and Redis container.

1. On the Render Dashboard, click **New +** and select **Web Service**.
2. Connect your GitHub repository fork.
3. Configure the service with the following settings:
   * **Name:** `securo-backend`
   * **Region:** (Must match your other services)
   * **Branch:** `main`
   * **Root Directory:** `backend`
   * **Runtime:** `Docker`
   * **Instance Type:** `Free`
4. ⚙️ **Configure Lifecycle Command (Crucial Step):**
   * Scroll down to the **Deploy** section.
   * Locate the **Docker Command** field (which overrides the default Dockerfile CMD).
   * Type exactly: `bash ./start.sh`
5. Click **Advanced** and populate the Environment Variables tables below:

#### 🛑 REQUIRED Environment Variables
These variables are strictly mandatory for the application to boot up and establish database/cache connections.

| Key | Suggested Value / Explanation |
| :--- | :--- |
| `DATABASE_URL` | Your modified Supabase Session Pooler connection string: `postgresql+asyncpg://postgres.[id]:[YOUR-PASSWORD]@...` |
| `REDIS_URL` | Your internal Render Redis string from Step 4: `redis://securo-redis:6379` |

#### ⚙️ OPTIONAL Environment Variables (Features)
These variables can be added later if you want to enable banking synchronization, or specific external integrations.

| Key | Suggested Value / Explanation |
| :--- | :--- |
| `PLUGGY_CLIENT_ID` | (Optional) Your Pluggy API Client ID for automatic bank sync. |
| `PLUGGY_CLIENT_SECRET`| (Optional) Your Pluggy API Client Secret. |
| `ENVIRONMENT` | `production` |

6. Click **Deploy Web Service**.
7. 🔄 **Final Step:** Once the backend deployment is complete, copy its public URL provided by Render (e.g., `https://securo-backend.onrender.com`). Go back to your **Frontend** service settings, update the `BACKEND_URL` variable with this address, and trigger a re-deploy of the frontend.
