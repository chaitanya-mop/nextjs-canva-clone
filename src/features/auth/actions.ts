"use server";

import { signIn } from "@/auth";
import { AuthError } from "next-auth";

export async function credentialsSignIn(email: string, password: string) {
  try {
    await signIn("credentials", {
      email,
      password,
      redirectTo: "/",
    });
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case "CredentialsSignin":
          return { error: "Invalid email or password" };
        default:
          return { error: "Something went wrong" };
      }
    }
    // Re-throw redirect errors (NEXT_REDIRECT)
    throw error;
  }
}
