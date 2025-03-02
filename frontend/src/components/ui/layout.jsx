import "@/src/index.css"
import { Inter } from "next/font/google"

const inter = Inter({ subsets: ["latin"] })

export const metadata = {
  title: "SportsConnectIndia - Connect with Athletes Across India",
  description: "Join our community of passionate athletes, find teammates, and elevate your game.",
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}

