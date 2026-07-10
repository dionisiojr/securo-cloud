--
-- PostgreSQL database dump
--
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid NOT NULL,
    connection_id uuid,
    external_id character varying(255),
    name character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    balance numeric(15,2) DEFAULT 0.00 NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying NOT NULL,
    user_id uuid NOT NULL,
    is_closed boolean DEFAULT false NOT NULL,
    closed_at timestamp with time zone,
    balance_primary numeric(15,2),
    credit_limit numeric(15,2),
    statement_close_day smallint,
    payment_due_day smallint,
    minimum_payment numeric(15,2),
    card_brand character varying(50),
    card_level character varying(50),
    display_name character varying(255),
    workspace_id uuid NOT NULL
);


--
-- Name: agent_conversations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_conversations (
    id uuid NOT NULL,
    agent_id uuid NOT NULL,
    user_id uuid NOT NULL,
    channel character varying(40) DEFAULT 'web'::character varying NOT NULL,
    title character varying(200),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: agent_knowledge_chunks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_knowledge_chunks (
    id uuid NOT NULL,
    doc_id uuid NOT NULL,
    agent_id uuid NOT NULL,
    ordinal integer NOT NULL,
    content text NOT NULL,
    embedding public.vector(1536),
    embedding_model character varying(120)
);


--
-- Name: agent_knowledge_docs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_knowledge_docs (
    id uuid NOT NULL,
    agent_id uuid NOT NULL,
    user_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    source character varying(500),
    mime character varying(80) NOT NULL,
    storage_path character varying(500),
    size_bytes integer DEFAULT 0 NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    error text,
    chunk_count integer DEFAULT 0 NOT NULL,
    pinned boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agent_llm_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_llm_connections (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(120) NOT NULL,
    kind character varying(40) NOT NULL,
    base_url character varying(500),
    api_key_encrypted character varying(500),
    default_model character varying(120),
    extra json DEFAULT '{}'::json NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agent_llm_usage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_llm_usage (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    agent_id uuid,
    conversation_id uuid,
    message_id uuid,
    provider character varying(40) NOT NULL,
    model character varying(120) NOT NULL,
    kind character varying(20) DEFAULT 'chat'::character varying NOT NULL,
    input_tokens integer DEFAULT 0 NOT NULL,
    output_tokens integer DEFAULT 0 NOT NULL,
    cost_usd numeric(10,6),
    latency_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agent_messages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_messages (
    id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    ordinal integer NOT NULL,
    role character varying(20) NOT NULL,
    content text,
    tool_calls json,
    tool_result json,
    citations json,
    input_tokens integer,
    output_tokens integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: agent_tools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agent_tools (
    agent_id uuid NOT NULL,
    server character varying(80) NOT NULL,
    tool_name character varying(120) NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


--
-- Name: agents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.agents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(120) NOT NULL,
    description text,
    system_prompt text DEFAULT ''::text NOT NULL,
    icon character varying(50) DEFAULT 'bot'::character varying NOT NULL,
    color character varying(7) DEFAULT '#6B7280'::character varying NOT NULL,
    provider character varying(40),
    model character varying(120),
    temperature double precision DEFAULT '0.4'::double precision NOT NULL,
    max_history_messages integer DEFAULT 20 NOT NULL,
    top_n integer DEFAULT 6 NOT NULL,
    similarity_threshold double precision DEFAULT '0.25'::double precision NOT NULL,
    extra json DEFAULT '{}'::json NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    connection_id uuid,
    auto_context boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: app_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_settings (
    key character varying(255) NOT NULL,
    value character varying(2000) NOT NULL
);


--
-- Name: asset_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_groups (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(50) DEFAULT 'wallet'::character varying NOT NULL,
    color character varying(7) DEFAULT '#0EA5E9'::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    source character varying(50) DEFAULT 'manual'::character varying NOT NULL,
    connection_id uuid,
    external_id character varying(255),
    workspace_id uuid NOT NULL
);


--
-- Name: asset_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_transactions (
    id uuid NOT NULL,
    asset_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    kind character varying(8) NOT NULL,
    quantity numeric(18,6) NOT NULL,
    price numeric(18,6) NOT NULL,
    fee numeric(15,2) DEFAULT '0'::numeric NOT NULL,
    date date NOT NULL,
    source character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    external_id character varying(255),
    notes character varying(500),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: asset_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asset_values (
    id uuid NOT NULL,
    asset_id uuid NOT NULL,
    amount numeric(15,6) NOT NULL,
    date date NOT NULL,
    source character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    workspace_id uuid NOT NULL,
    price numeric(18,6)
);


--
-- Name: assets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(50) NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying NOT NULL,
    units numeric(15,6),
    valuation_method character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    purchase_date date,
    purchase_price numeric(15,2),
    sell_date date,
    sell_price numeric(15,2),
    growth_type character varying(20),
    growth_rate numeric(15,6),
    growth_frequency character varying(20),
    growth_start_date date,
    is_archived boolean DEFAULT false NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    purchase_price_primary numeric(15,2),
    connection_id uuid,
    external_id character varying(255),
    source character varying(50) DEFAULT 'manual'::character varying NOT NULL,
    isin character varying(20),
    maturity_date date,
    external_metadata json,
    group_id uuid,
    ticker character varying(32),
    ticker_exchange character varying(32),
    last_price numeric(18,6),
    last_price_at timestamp with time zone,
    logo_url character varying(500),
    workspace_id uuid NOT NULL,
    average_price numeric(18,6),
    realized_gain numeric(18,2)
);


--
-- Name: bank_connections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bank_connections (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    provider character varying(50) NOT NULL,
    external_id character varying(255) NOT NULL,
    institution_name character varying(255) NOT NULL,
    credentials json,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    last_sync_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    settings json DEFAULT '{}'::json,
    display_name character varying(255),
    workspace_id uuid NOT NULL,
    logo_url character varying(500)
);


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    category_id uuid NOT NULL,
    amount numeric(15,2) NOT NULL,
    month date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    is_recurring boolean DEFAULT false NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying,
    amount_primary numeric(15,2),
    workspace_id uuid NOT NULL
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(50) DEFAULT '❓'::character varying NOT NULL,
    color character varying(7) DEFAULT '#6B7280'::character varying NOT NULL,
    is_system boolean DEFAULT false NOT NULL,
    group_id uuid,
    treat_as_transfer boolean DEFAULT false NOT NULL,
    is_ignored boolean DEFAULT false NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: category_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.category_groups (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(50) DEFAULT 'folder'::character varying NOT NULL,
    color character varying(7) DEFAULT '#6B7280'::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    is_system boolean DEFAULT true NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: collection_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_accounts (
    collection_id uuid NOT NULL,
    account_id uuid NOT NULL
);


--
-- Name: collection_asset_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collection_asset_groups (
    collection_id uuid NOT NULL,
    asset_group_id uuid NOT NULL
);


--
-- Name: collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collections (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(50) DEFAULT 'folder'::character varying NOT NULL,
    color character varying(7) DEFAULT '#6366F1'::character varying NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: credit_card_bills; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.credit_card_bills (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid NOT NULL,
    external_id character varying(255) NOT NULL,
    due_date date NOT NULL,
    total_amount numeric(15,2) NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying NOT NULL,
    minimum_payment numeric(15,2),
    raw_data json,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: fx_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fx_rates (
    id uuid NOT NULL,
    base_currency character varying(3) NOT NULL,
    quote_currency character varying(3) NOT NULL,
    date date NOT NULL,
    rate numeric(20,10) NOT NULL,
    source character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: goals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.goals (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    target_amount numeric(15,2) NOT NULL,
    current_amount numeric(15,2) DEFAULT '0'::numeric NOT NULL,
    currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    target_amount_primary numeric(15,2),
    current_amount_primary numeric(15,2),
    target_date date,
    tracking_type character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    account_id uuid,
    status character varying(20) DEFAULT 'active'::character varying NOT NULL,
    icon character varying(50),
    color character varying(7),
    "position" integer DEFAULT 0 NOT NULL,
    metadata_json json,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    initial_amount numeric(15,2) DEFAULT 0.00 NOT NULL,
    asset_id uuid,
    workspace_id uuid NOT NULL,
    asset_group_id uuid
);


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_members (
    id uuid NOT NULL,
    group_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    linked_user_id uuid,
    email character varying(255),
    is_self boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: group_settlements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.group_settlements (
    id uuid NOT NULL,
    group_id uuid NOT NULL,
    from_member_id uuid NOT NULL,
    to_member_id uuid NOT NULL,
    amount numeric(15,2) NOT NULL,
    currency character varying(3) NOT NULL,
    date date NOT NULL,
    transaction_id uuid,
    notes character varying(1000),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    receiver_transaction_id uuid,
    workspace_id uuid NOT NULL
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.groups (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    kind character varying(20) DEFAULT 'social'::character varying NOT NULL,
    default_currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    icon character varying(50) DEFAULT 'users'::character varying NOT NULL,
    color character varying(7) DEFAULT '#6B7280'::character varying NOT NULL,
    is_archived boolean DEFAULT false NOT NULL,
    notes character varying(1000),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: import_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_logs (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid NOT NULL,
    filename character varying(255) NOT NULL,
    format character varying(10) NOT NULL,
    transaction_count integer NOT NULL,
    total_credit numeric(15,2) DEFAULT '0'::numeric NOT NULL,
    total_debit numeric(15,2) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: payee_mapping; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payee_mapping (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    target_id uuid NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: payees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payees (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(20) DEFAULT 'merchant'::character varying NOT NULL,
    is_favorite boolean DEFAULT false NOT NULL,
    notes character varying(1000),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: recurring_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurring_transactions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    account_id uuid,
    category_id uuid,
    description character varying(500) NOT NULL,
    amount numeric(15,2) NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying NOT NULL,
    type character varying(10) NOT NULL,
    frequency character varying(20) NOT NULL,
    day_of_month integer,
    start_date date NOT NULL,
    end_date date,
    is_active boolean DEFAULT true NOT NULL,
    next_occurrence date NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    amount_primary numeric(15,2),
    fx_rate_used numeric(20,10),
    workspace_id uuid NOT NULL
);


--
-- Name: rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rules (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    name character varying(255) NOT NULL,
    conditions_op character varying(3) DEFAULT 'and'::character varying NOT NULL,
    conditions json DEFAULT '[]'::json NOT NULL,
    actions json DEFAULT '[]'::json NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: transaction_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_attachments (
    id uuid NOT NULL,
    transaction_id uuid NOT NULL,
    user_id uuid NOT NULL,
    filename character varying(255) NOT NULL,
    storage_key character varying(500) NOT NULL,
    content_type character varying(100) NOT NULL,
    size bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: transaction_splits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_splits (
    id uuid NOT NULL,
    transaction_id uuid NOT NULL,
    group_member_id uuid NOT NULL,
    share_amount numeric(15,2) NOT NULL,
    share_type character varying(10) DEFAULT 'exact'::character varying NOT NULL,
    share_pct numeric(5,2),
    notes character varying(500),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id uuid NOT NULL,
    account_id uuid NOT NULL,
    category_id uuid,
    external_id character varying(255),
    description character varying(500) NOT NULL,
    amount numeric(15,2) NOT NULL,
    date date NOT NULL,
    type character varying(10) NOT NULL,
    source character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid NOT NULL,
    currency character varying(3) DEFAULT 'BRL'::character varying NOT NULL,
    notes text,
    import_id uuid,
    transfer_pair_id uuid,
    status character varying(10) DEFAULT 'posted'::character varying NOT NULL,
    payee character varying(500),
    raw_data jsonb,
    amount_primary numeric(15,2),
    fx_rate_used numeric(20,10),
    payee_id uuid,
    effective_date date NOT NULL,
    installment_number smallint,
    total_installments smallint,
    installment_total_amount numeric(15,2),
    installment_purchase_date date,
    bill_id uuid,
    effective_bill_date date,
    is_ignored boolean DEFAULT false NOT NULL,
    workspace_id uuid NOT NULL
);


--
-- Name: user_passkeys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_passkeys (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    credential_id character varying(512) NOT NULL,
    public_key text NOT NULL,
    sign_count integer DEFAULT 0 NOT NULL,
    name character varying(100) NOT NULL,
    transports json,
    aaguid character varying(64),
    device_type character varying(50),
    backed_up boolean,
    created_at timestamp with time zone NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email character varying(320) NOT NULL,
    hashed_password character varying(1024) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    is_superuser boolean DEFAULT false NOT NULL,
    is_verified boolean DEFAULT false NOT NULL,
    preferences json,
    totp_secret character varying(32),
    is_2fa_enabled boolean DEFAULT false NOT NULL,
    oidc_issuer character varying(255),
    oidc_subject character varying(255)
);


--
-- Name: workspace_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspace_members (
    id uuid NOT NULL,
    workspace_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role character varying(20) DEFAULT 'owner'::character varying NOT NULL,
    invited_by_user_id uuid,
    joined_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    kind character varying(30) DEFAULT 'personal'::character varying NOT NULL,
    created_by_user_id uuid,
    is_archived boolean DEFAULT false NOT NULL,
    default_currency character varying(3) DEFAULT 'USD'::character varying NOT NULL,
    locale character varying(10),
    icon character varying(50),
    color character varying(7),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    managed_by_user_id uuid
);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: agent_conversations agent_conversations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_pkey PRIMARY KEY (id);


--
-- Name: agent_knowledge_chunks agent_knowledge_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_chunks
    ADD CONSTRAINT agent_knowledge_chunks_pkey PRIMARY KEY (id);


--
-- Name: agent_knowledge_docs agent_knowledge_docs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_docs
    ADD CONSTRAINT agent_knowledge_docs_pkey PRIMARY KEY (id);


--
-- Name: agent_llm_connections agent_llm_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_connections
    ADD CONSTRAINT agent_llm_connections_pkey PRIMARY KEY (id);


--
-- Name: agent_llm_usage agent_llm_usage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_usage
    ADD CONSTRAINT agent_llm_usage_pkey PRIMARY KEY (id);


--
-- Name: agent_messages agent_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_messages
    ADD CONSTRAINT agent_messages_pkey PRIMARY KEY (id);


--
-- Name: agent_tools agent_tools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_tools
    ADD CONSTRAINT agent_tools_pkey PRIMARY KEY (agent_id, server, tool_name);


--
-- Name: agents agents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: app_settings app_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_settings
    ADD CONSTRAINT app_settings_pkey PRIMARY KEY (key);


--
-- Name: asset_groups asset_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_groups
    ADD CONSTRAINT asset_groups_pkey PRIMARY KEY (id);


--
-- Name: asset_transactions asset_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_transactions
    ADD CONSTRAINT asset_transactions_pkey PRIMARY KEY (id);


--
-- Name: asset_values asset_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_values
    ADD CONSTRAINT asset_values_pkey PRIMARY KEY (id);


--
-- Name: assets assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (id);


--
-- Name: bank_connections bank_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_connections
    ADD CONSTRAINT bank_connections_pkey PRIMARY KEY (id);


--
-- Name: budgets budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: category_groups category_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_pkey PRIMARY KEY (id);


--
-- Name: collection_accounts collection_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_accounts
    ADD CONSTRAINT collection_accounts_pkey PRIMARY KEY (collection_id, account_id);


--
-- Name: collection_asset_groups collection_asset_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_asset_groups
    ADD CONSTRAINT collection_asset_groups_pkey PRIMARY KEY (collection_id, asset_group_id);


--
-- Name: collections collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_pkey PRIMARY KEY (id);


--
-- Name: credit_card_bills credit_card_bills_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_bills
    ADD CONSTRAINT credit_card_bills_pkey PRIMARY KEY (id);


--
-- Name: fx_rates fx_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fx_rates
    ADD CONSTRAINT fx_rates_pkey PRIMARY KEY (id);


--
-- Name: goals goals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: group_settlements group_settlements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: import_logs import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_logs
    ADD CONSTRAINT import_logs_pkey PRIMARY KEY (id);


--
-- Name: payee_mapping payee_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payee_mapping
    ADD CONSTRAINT payee_mapping_pkey PRIMARY KEY (id);


--
-- Name: payees payees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payees
    ADD CONSTRAINT payees_pkey PRIMARY KEY (id);


--
-- Name: recurring_transactions recurring_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: transaction_attachments transaction_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_attachments
    ADD CONSTRAINT transaction_attachments_pkey PRIMARY KEY (id);


--
-- Name: transaction_splits transaction_splits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_splits
    ADD CONSTRAINT transaction_splits_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: budgets uq_budget_per_category_month_type; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT uq_budget_per_category_month_type UNIQUE (user_id, category_id, month, is_recurring);


--
-- Name: credit_card_bills uq_cc_bills_account_external_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_bills
    ADD CONSTRAINT uq_cc_bills_account_external_id UNIQUE (account_id, external_id);


--
-- Name: fx_rates uq_fx_rate_base_quote_date; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fx_rates
    ADD CONSTRAINT uq_fx_rate_base_quote_date UNIQUE (base_currency, quote_currency, date);


--
-- Name: group_members uq_group_members_group_id_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT uq_group_members_group_id_name UNIQUE (group_id, name);


--
-- Name: groups uq_groups_user_id_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT uq_groups_user_id_name UNIQUE (user_id, name);


--
-- Name: payees uq_payees_user_id_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payees
    ADD CONSTRAINT uq_payees_user_id_name UNIQUE (user_id, name);


--
-- Name: recurring_transactions uq_recurring_tx; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT uq_recurring_tx UNIQUE (user_id, description, frequency, start_date);


--
-- Name: transaction_splits uq_transaction_splits_tx_member; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_splits
    ADD CONSTRAINT uq_transaction_splits_tx_member UNIQUE (transaction_id, group_member_id);


--
-- Name: users uq_users_oidc_identity; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT uq_users_oidc_identity UNIQUE (oidc_issuer, oidc_subject);


--
-- Name: workspace_members uq_workspace_member; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT uq_workspace_member UNIQUE (workspace_id, user_id);


--
-- Name: user_passkeys user_passkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passkeys
    ADD CONSTRAINT user_passkeys_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workspace_members workspace_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: ix_accounts_connection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_accounts_connection_id ON public.accounts USING btree (connection_id);


--
-- Name: ix_accounts_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_accounts_user_id ON public.accounts USING btree (user_id);


--
-- Name: ix_accounts_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_accounts_workspace_id ON public.accounts USING btree (workspace_id);


--
-- Name: ix_agent_conversations_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_conversations_agent_id ON public.agent_conversations USING btree (agent_id);


--
-- Name: ix_agent_conversations_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_conversations_user_id ON public.agent_conversations USING btree (user_id);


--
-- Name: ix_agent_conversations_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_conversations_workspace_id ON public.agent_conversations USING btree (workspace_id);


--
-- Name: ix_agent_knowledge_chunks_doc_ord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_knowledge_chunks_doc_ord ON public.agent_knowledge_chunks USING btree (doc_id, ordinal);


--
-- Name: ix_agent_knowledge_chunks_embedding; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_knowledge_chunks_embedding ON public.agent_knowledge_chunks USING ivfflat (embedding public.vector_cosine_ops) WITH (lists='100');


--
-- Name: ix_agent_knowledge_docs_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_knowledge_docs_agent_id ON public.agent_knowledge_docs USING btree (agent_id);


--
-- Name: ix_agent_llm_connections_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_llm_connections_user_id ON public.agent_llm_connections USING btree (user_id);


--
-- Name: ix_agent_llm_usage_agent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_llm_usage_agent_id ON public.agent_llm_usage USING btree (agent_id);


--
-- Name: ix_agent_llm_usage_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_llm_usage_user_id ON public.agent_llm_usage USING btree (user_id);


--
-- Name: ix_agent_messages_conv_ord; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agent_messages_conv_ord ON public.agent_messages USING btree (conversation_id, ordinal);


--
-- Name: ix_agents_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agents_user_id ON public.agents USING btree (user_id);


--
-- Name: ix_agents_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_agents_workspace_id ON public.agents USING btree (workspace_id);


--
-- Name: ix_asset_groups_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_groups_user_id ON public.asset_groups USING btree (user_id);


--
-- Name: ix_asset_groups_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_groups_workspace_id ON public.asset_groups USING btree (workspace_id);


--
-- Name: ix_asset_transactions_asset_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_transactions_asset_id ON public.asset_transactions USING btree (asset_id);


--
-- Name: ix_asset_transactions_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_transactions_date ON public.asset_transactions USING btree (date);


--
-- Name: ix_asset_transactions_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_transactions_workspace_id ON public.asset_transactions USING btree (workspace_id);


--
-- Name: ix_asset_values_asset_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_values_asset_date ON public.asset_values USING btree (asset_id, date);


--
-- Name: ix_asset_values_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_asset_values_workspace_id ON public.asset_values USING btree (workspace_id);


--
-- Name: ix_assets_connection_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assets_connection_id ON public.assets USING btree (connection_id);


--
-- Name: ix_assets_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assets_group_id ON public.assets USING btree (group_id);


--
-- Name: ix_assets_market_price; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assets_market_price ON public.assets USING btree (valuation_method) WHERE ((valuation_method)::text = 'market_price'::text);


--
-- Name: ix_assets_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assets_user_id ON public.assets USING btree (user_id);


--
-- Name: ix_assets_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_assets_workspace_id ON public.assets USING btree (workspace_id);


--
-- Name: ix_bank_connections_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bank_connections_user_id ON public.bank_connections USING btree (user_id);


--
-- Name: ix_bank_connections_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_bank_connections_workspace_id ON public.bank_connections USING btree (workspace_id);


--
-- Name: ix_budgets_recurring_lookup; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_budgets_recurring_lookup ON public.budgets USING btree (user_id, category_id, month) WHERE (is_recurring = true);


--
-- Name: ix_budgets_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_budgets_user_id ON public.budgets USING btree (user_id);


--
-- Name: ix_budgets_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_budgets_workspace_id ON public.budgets USING btree (workspace_id);


--
-- Name: ix_categories_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_user_id ON public.categories USING btree (user_id);


--
-- Name: ix_categories_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_categories_workspace_id ON public.categories USING btree (workspace_id);


--
-- Name: ix_category_groups_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_category_groups_user_id ON public.category_groups USING btree (user_id);


--
-- Name: ix_category_groups_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_category_groups_workspace_id ON public.category_groups USING btree (workspace_id);


--
-- Name: ix_collections_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_collections_workspace_id ON public.collections USING btree (workspace_id);


--
-- Name: ix_credit_card_bills_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_bills_account_id ON public.credit_card_bills USING btree (account_id);


--
-- Name: ix_credit_card_bills_due_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_bills_due_date ON public.credit_card_bills USING btree (due_date);


--
-- Name: ix_credit_card_bills_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_credit_card_bills_workspace_id ON public.credit_card_bills USING btree (workspace_id);


--
-- Name: ix_fx_rates_quote_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_fx_rates_quote_date ON public.fx_rates USING btree (quote_currency, date);


--
-- Name: ix_goals_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_goals_user_id ON public.goals USING btree (user_id);


--
-- Name: ix_goals_user_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_goals_user_status ON public.goals USING btree (user_id, status);


--
-- Name: ix_goals_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_goals_workspace_id ON public.goals USING btree (workspace_id);


--
-- Name: ix_group_members_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_members_group_id ON public.group_members USING btree (group_id);


--
-- Name: ix_group_members_linked_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_members_linked_user_id ON public.group_members USING btree (linked_user_id);


--
-- Name: ix_group_members_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_members_workspace_id ON public.group_members USING btree (workspace_id);


--
-- Name: ix_group_settlements_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_settlements_group_id ON public.group_settlements USING btree (group_id);


--
-- Name: ix_group_settlements_receiver_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_settlements_receiver_transaction_id ON public.group_settlements USING btree (receiver_transaction_id);


--
-- Name: ix_group_settlements_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_settlements_transaction_id ON public.group_settlements USING btree (transaction_id);


--
-- Name: ix_group_settlements_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_group_settlements_workspace_id ON public.group_settlements USING btree (workspace_id);


--
-- Name: ix_groups_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_groups_user_id ON public.groups USING btree (user_id);


--
-- Name: ix_groups_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_groups_workspace_id ON public.groups USING btree (workspace_id);


--
-- Name: ix_import_logs_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_import_logs_user_id ON public.import_logs USING btree (user_id);


--
-- Name: ix_import_logs_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_import_logs_workspace_id ON public.import_logs USING btree (workspace_id);


--
-- Name: ix_payee_mapping_user_id_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payee_mapping_user_id_target_id ON public.payee_mapping USING btree (user_id, target_id);


--
-- Name: ix_payee_mapping_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payee_mapping_workspace_id ON public.payee_mapping USING btree (workspace_id);


--
-- Name: ix_payees_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payees_user_id ON public.payees USING btree (user_id);


--
-- Name: ix_payees_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_payees_workspace_id ON public.payees USING btree (workspace_id);


--
-- Name: ix_recurring_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recurring_transactions_user_id ON public.recurring_transactions USING btree (user_id);


--
-- Name: ix_recurring_transactions_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_recurring_transactions_workspace_id ON public.recurring_transactions USING btree (workspace_id);


--
-- Name: ix_rules_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_rules_user_id ON public.rules USING btree (user_id);


--
-- Name: ix_rules_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_rules_workspace_id ON public.rules USING btree (workspace_id);


--
-- Name: ix_transaction_attachments_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_attachments_transaction_id ON public.transaction_attachments USING btree (transaction_id);


--
-- Name: ix_transaction_attachments_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_attachments_user_id ON public.transaction_attachments USING btree (user_id);


--
-- Name: ix_transaction_attachments_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_attachments_workspace_id ON public.transaction_attachments USING btree (workspace_id);


--
-- Name: ix_transaction_splits_group_member_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_splits_group_member_id ON public.transaction_splits USING btree (group_member_id);


--
-- Name: ix_transaction_splits_transaction_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_splits_transaction_id ON public.transaction_splits USING btree (transaction_id);


--
-- Name: ix_transaction_splits_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transaction_splits_workspace_id ON public.transaction_splits USING btree (workspace_id);


--
-- Name: ix_transactions_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_account_id ON public.transactions USING btree (account_id);


--
-- Name: ix_transactions_bill_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_bill_id ON public.transactions USING btree (bill_id);


--
-- Name: ix_transactions_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_category_id ON public.transactions USING btree (category_id);


--
-- Name: ix_transactions_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_date ON public.transactions USING btree (date);


--
-- Name: ix_transactions_effective_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_effective_date ON public.transactions USING btree (effective_date);


--
-- Name: ix_transactions_is_ignored; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_is_ignored ON public.transactions USING btree (is_ignored);


--
-- Name: ix_transactions_payee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_payee_id ON public.transactions USING btree (payee_id);


--
-- Name: ix_transactions_transfer_match; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_transfer_match ON public.transactions USING btree (user_id, amount, date) WHERE (transfer_pair_id IS NULL);


--
-- Name: ix_transactions_transfer_pair_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_transfer_pair_id ON public.transactions USING btree (transfer_pair_id) WHERE (transfer_pair_id IS NOT NULL);


--
-- Name: ix_transactions_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_user_id ON public.transactions USING btree (user_id);


--
-- Name: ix_transactions_workspace_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_transactions_workspace_id ON public.transactions USING btree (workspace_id);


--
-- Name: ix_user_passkeys_credential_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_user_passkeys_credential_id ON public.user_passkeys USING btree (credential_id);


--
-- Name: ix_user_passkeys_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_passkeys_user_id ON public.user_passkeys USING btree (user_id);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_oidc_issuer; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_oidc_issuer ON public.users USING btree (oidc_issuer);


--
-- Name: ix_users_oidc_subject; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_oidc_subject ON public.users USING btree (oidc_subject);


--
-- Name: ix_workspace_members_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspace_members_user ON public.workspace_members USING btree (user_id);


--
-- Name: ix_workspace_members_workspace; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspace_members_workspace ON public.workspace_members USING btree (workspace_id);


--
-- Name: ix_workspaces_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspaces_kind ON public.workspaces USING btree (kind);


--
-- Name: ix_workspaces_managed_by_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_workspaces_managed_by_user_id ON public.workspaces USING btree (managed_by_user_id);


--
-- Name: uq_agents_one_default_per_user; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX uq_agents_one_default_per_user ON public.agents USING btree (user_id) WHERE (is_default = true);


--
-- Name: ux_asset_groups_user_source_external; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_asset_groups_user_source_external ON public.asset_groups USING btree (user_id, source, external_id) WHERE (external_id IS NOT NULL);


--
-- Name: ux_assets_user_source_external; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ux_assets_user_source_external ON public.assets USING btree (user_id, source, external_id) WHERE (external_id IS NOT NULL);


--
-- Name: accounts accounts_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.bank_connections(id);


--
-- Name: accounts accounts_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: agent_conversations agent_conversations_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE CASCADE;


--
-- Name: agent_conversations agent_conversations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agent_conversations agent_conversations_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_conversations
    ADD CONSTRAINT agent_conversations_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: agent_knowledge_chunks agent_knowledge_chunks_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_chunks
    ADD CONSTRAINT agent_knowledge_chunks_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE CASCADE;


--
-- Name: agent_knowledge_chunks agent_knowledge_chunks_doc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_chunks
    ADD CONSTRAINT agent_knowledge_chunks_doc_id_fkey FOREIGN KEY (doc_id) REFERENCES public.agent_knowledge_docs(id) ON DELETE CASCADE;


--
-- Name: agent_knowledge_docs agent_knowledge_docs_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_docs
    ADD CONSTRAINT agent_knowledge_docs_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE CASCADE;


--
-- Name: agent_knowledge_docs agent_knowledge_docs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_knowledge_docs
    ADD CONSTRAINT agent_knowledge_docs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agent_llm_connections agent_llm_connections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_connections
    ADD CONSTRAINT agent_llm_connections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agent_llm_usage agent_llm_usage_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_usage
    ADD CONSTRAINT agent_llm_usage_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE SET NULL;


--
-- Name: agent_llm_usage agent_llm_usage_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_usage
    ADD CONSTRAINT agent_llm_usage_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.agent_conversations(id) ON DELETE SET NULL;


--
-- Name: agent_llm_usage agent_llm_usage_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_usage
    ADD CONSTRAINT agent_llm_usage_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.agent_messages(id) ON DELETE SET NULL;


--
-- Name: agent_llm_usage agent_llm_usage_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_llm_usage
    ADD CONSTRAINT agent_llm_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agent_messages agent_messages_conversation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_messages
    ADD CONSTRAINT agent_messages_conversation_id_fkey FOREIGN KEY (conversation_id) REFERENCES public.agent_conversations(id) ON DELETE CASCADE;


--
-- Name: agent_tools agent_tools_agent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agent_tools
    ADD CONSTRAINT agent_tools_agent_id_fkey FOREIGN KEY (agent_id) REFERENCES public.agents(id) ON DELETE CASCADE;


--
-- Name: agents agents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: agents agents_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT agents_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: asset_groups asset_groups_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_groups
    ADD CONSTRAINT asset_groups_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.bank_connections(id) ON DELETE SET NULL;


--
-- Name: asset_groups asset_groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_groups
    ADD CONSTRAINT asset_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: asset_groups asset_groups_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_groups
    ADD CONSTRAINT asset_groups_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: asset_transactions asset_transactions_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_transactions
    ADD CONSTRAINT asset_transactions_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: asset_transactions asset_transactions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_transactions
    ADD CONSTRAINT asset_transactions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: asset_values asset_values_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_values
    ADD CONSTRAINT asset_values_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id) ON DELETE CASCADE;


--
-- Name: asset_values asset_values_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asset_values
    ADD CONSTRAINT asset_values_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: assets assets_connection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_connection_id_fkey FOREIGN KEY (connection_id) REFERENCES public.bank_connections(id) ON DELETE SET NULL;


--
-- Name: assets assets_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.asset_groups(id) ON DELETE SET NULL;


--
-- Name: assets assets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: assets assets_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assets
    ADD CONSTRAINT assets_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: bank_connections bank_connections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_connections
    ADD CONSTRAINT bank_connections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: bank_connections bank_connections_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bank_connections
    ADD CONSTRAINT bank_connections_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: budgets budgets_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: budgets budgets_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: budgets budgets_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: categories categories_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.category_groups(id);


--
-- Name: categories categories_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: categories categories_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: category_groups category_groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: category_groups category_groups_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT category_groups_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: collection_accounts collection_accounts_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_accounts
    ADD CONSTRAINT collection_accounts_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: collection_accounts collection_accounts_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_accounts
    ADD CONSTRAINT collection_accounts_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collection_asset_groups collection_asset_groups_asset_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_asset_groups
    ADD CONSTRAINT collection_asset_groups_asset_group_id_fkey FOREIGN KEY (asset_group_id) REFERENCES public.asset_groups(id) ON DELETE CASCADE;


--
-- Name: collection_asset_groups collection_asset_groups_collection_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collection_asset_groups
    ADD CONSTRAINT collection_asset_groups_collection_id_fkey FOREIGN KEY (collection_id) REFERENCES public.collections(id) ON DELETE CASCADE;


--
-- Name: collections collections_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: collections collections_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collections
    ADD CONSTRAINT collections_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: credit_card_bills credit_card_bills_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_bills
    ADD CONSTRAINT credit_card_bills_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: credit_card_bills credit_card_bills_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_bills
    ADD CONSTRAINT credit_card_bills_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: credit_card_bills credit_card_bills_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.credit_card_bills
    ADD CONSTRAINT credit_card_bills_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: accounts fk_accounts_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT fk_accounts_user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: agents fk_agents_connection_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.agents
    ADD CONSTRAINT fk_agents_connection_id FOREIGN KEY (connection_id) REFERENCES public.agent_llm_connections(id) ON DELETE SET NULL;


--
-- Name: goals fk_goals_asset_group_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT fk_goals_asset_group_id FOREIGN KEY (asset_group_id) REFERENCES public.asset_groups(id) ON DELETE SET NULL;


--
-- Name: transactions fk_transactions_user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT fk_transactions_user_id FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: goals goals_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE SET NULL;


--
-- Name: goals goals_asset_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_asset_id_fkey FOREIGN KEY (asset_id) REFERENCES public.assets(id);


--
-- Name: goals goals_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: goals goals_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.goals
    ADD CONSTRAINT goals_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_members group_members_linked_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_linked_user_id_fkey FOREIGN KEY (linked_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: group_members group_members_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: group_settlements group_settlements_from_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_from_member_id_fkey FOREIGN KEY (from_member_id) REFERENCES public.group_members(id) ON DELETE RESTRICT;


--
-- Name: group_settlements group_settlements_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: group_settlements group_settlements_receiver_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_receiver_transaction_id_fkey FOREIGN KEY (receiver_transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: group_settlements group_settlements_to_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_to_member_id_fkey FOREIGN KEY (to_member_id) REFERENCES public.group_members(id) ON DELETE RESTRICT;


--
-- Name: group_settlements group_settlements_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: group_settlements group_settlements_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.group_settlements
    ADD CONSTRAINT group_settlements_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: groups groups_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: import_logs import_logs_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_logs
    ADD CONSTRAINT import_logs_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: import_logs import_logs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_logs
    ADD CONSTRAINT import_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: import_logs import_logs_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_logs
    ADD CONSTRAINT import_logs_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: payee_mapping payee_mapping_target_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payee_mapping
    ADD CONSTRAINT payee_mapping_target_id_fkey FOREIGN KEY (target_id) REFERENCES public.payees(id) ON DELETE CASCADE;


--
-- Name: payee_mapping payee_mapping_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payee_mapping
    ADD CONSTRAINT payee_mapping_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payee_mapping payee_mapping_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payee_mapping
    ADD CONSTRAINT payee_mapping_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: payees payees_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payees
    ADD CONSTRAINT payees_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: payees payees_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payees
    ADD CONSTRAINT payees_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: recurring_transactions recurring_transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: recurring_transactions recurring_transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: recurring_transactions recurring_transactions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: recurring_transactions recurring_transactions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurring_transactions
    ADD CONSTRAINT recurring_transactions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: rules rules_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: rules rules_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: transaction_attachments transaction_attachments_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_attachments
    ADD CONSTRAINT transaction_attachments_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: transaction_attachments transaction_attachments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_attachments
    ADD CONSTRAINT transaction_attachments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: transaction_attachments transaction_attachments_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_attachments
    ADD CONSTRAINT transaction_attachments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: transaction_splits transaction_splits_group_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_splits
    ADD CONSTRAINT transaction_splits_group_member_id_fkey FOREIGN KEY (group_member_id) REFERENCES public.group_members(id) ON DELETE RESTRICT;


--
-- Name: transaction_splits transaction_splits_transaction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_splits
    ADD CONSTRAINT transaction_splits_transaction_id_fkey FOREIGN KEY (transaction_id) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: transaction_splits transaction_splits_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_splits
    ADD CONSTRAINT transaction_splits_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_id_fkey FOREIGN KEY (account_id) REFERENCES public.accounts(id);


--
-- Name: transactions transactions_bill_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_bill_id_fkey FOREIGN KEY (bill_id) REFERENCES public.credit_card_bills(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);


--
-- Name: transactions transactions_import_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_import_id_fkey FOREIGN KEY (import_id) REFERENCES public.import_logs(id);


--
-- Name: transactions transactions_payee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_payee_id_fkey FOREIGN KEY (payee_id) REFERENCES public.payees(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: user_passkeys user_passkeys_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_passkeys
    ADD CONSTRAINT user_passkeys_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workspace_members workspace_members_invited_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_invited_by_user_id_fkey FOREIGN KEY (invited_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspace_members workspace_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: workspace_members workspace_members_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspace_members
    ADD CONSTRAINT workspace_members_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspaces workspaces_created_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_created_by_user_id_fkey FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: workspaces workspaces_managed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_managed_by_user_id_fkey FOREIGN KEY (managed_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


-- [ADICIONADO NO FORK CLOUD] - Ajuste físico para suportar transações recorrentes em produção
ALTER TABLE transactions 
ADD COLUMN IF NOT EXISTS recurring_transaction_id UUID REFERENCES recurring_transactions(id) ON DELETE SET NULL;

--
-- PostgreSQL database dump complete
--