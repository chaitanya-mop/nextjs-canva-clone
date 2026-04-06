-- Canva Clone — full schema migration
-- Run once against the Neon database to create all required tables.

CREATE TABLE IF NOT EXISTS "account" (
  "userId" text NOT NULL,
  "type" text NOT NULL,
  "provider" text NOT NULL,
  "providerAccountId" text NOT NULL,
  "refresh_token" text,
  "access_token" text,
  "expires_at" integer,
  "token_type" text,
  "scope" text,
  "id_token" text,
  "session_state" text,
  CONSTRAINT "account_provider_providerAccountId_pk" PRIMARY KEY("provider","providerAccountId")
);

CREATE TABLE IF NOT EXISTS "authenticator" (
  "credentialID" text NOT NULL,
  "userId" text NOT NULL,
  "providerAccountId" text NOT NULL,
  "credentialPublicKey" text NOT NULL,
  "counter" integer NOT NULL,
  "credentialDeviceType" text NOT NULL,
  "credentialBackedUp" boolean NOT NULL,
  "transports" text,
  CONSTRAINT "authenticator_userId_credentialID_pk" PRIMARY KEY("userId","credentialID"),
  CONSTRAINT "authenticator_credentialID_unique" UNIQUE("credentialID")
);

CREATE TABLE IF NOT EXISTS "session" (
  "sessionToken" text PRIMARY KEY NOT NULL,
  "userId" text NOT NULL,
  "expires" timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS "user" (
  "id" text PRIMARY KEY NOT NULL,
  "name" text,
  "email" text NOT NULL,
  "emailVerified" timestamp,
  "image" text
);

CREATE TABLE IF NOT EXISTS "verificationToken" (
  "identifier" text NOT NULL,
  "token" text NOT NULL,
  "expires" timestamp NOT NULL,
  CONSTRAINT "verificationToken_identifier_token_pk" PRIMARY KEY("identifier","token")
);

ALTER TABLE "user" ADD COLUMN IF NOT EXISTS "password" text;

DO $$ BEGIN
  ALTER TABLE "account" ADD CONSTRAINT "account_userId_user_id_fk"
    FOREIGN KEY ("userId") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
  EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "authenticator" ADD CONSTRAINT "authenticator_userId_user_id_fk"
    FOREIGN KEY ("userId") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
  EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  ALTER TABLE "session" ADD CONSTRAINT "session_userId_user_id_fk"
    FOREIGN KEY ("userId") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
  EXCEPTION WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS "project" (
  "id" text PRIMARY KEY NOT NULL,
  "name" text NOT NULL,
  "userId" text NOT NULL,
  "json" text NOT NULL,
  "height" integer NOT NULL,
  "width" integer NOT NULL,
  "thumbnailUrl" text,
  "isTemplate" boolean,
  "isPro" boolean,
  "createdAt" timestamp NOT NULL,
  "updatedAt" timestamp NOT NULL
);

DO $$ BEGIN
  ALTER TABLE "project" ADD CONSTRAINT "project_userId_user_id_fk"
    FOREIGN KEY ("userId") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
  EXCEPTION WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS "subscription" (
  "id" text PRIMARY KEY NOT NULL,
  "userId" text NOT NULL,
  "subscriptionId" text NOT NULL,
  "customerId" text NOT NULL,
  "priceId" text NOT NULL,
  "status" text NOT NULL,
  "currentPeriodEnd" timestamp,
  "createdAt" timestamp NOT NULL,
  "updatedAt" timestamp NOT NULL
);

DO $$ BEGIN
  ALTER TABLE "subscription" ADD CONSTRAINT "subscription_userId_user_id_fk"
    FOREIGN KEY ("userId") REFERENCES "public"."user"("id") ON DELETE cascade ON UPDATE no action;
  EXCEPTION WHEN duplicate_object THEN null;
END $$;
