import type { Metadata } from "next";
import { Ubuntu } from "next/font/google";
import "./globals.css";
import '@mantine/core/styles.css';
import { ColorSchemeScript, MantineProvider, mantineHtmlProps } from '@mantine/core';

const ubuntu = Ubuntu({
  subsets: ["latin"],
  weight: ['400', '500', '700'],
  variable: "--font-ubuntu",
});

export const metadata: Metadata = {
  title: "Multi Step Form",
  description: "A multi step form with Mantine",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" {...mantineHtmlProps}>
      <head>
        <ColorSchemeScript />
      </head>
      <body className={ubuntu.variable}>
        <MantineProvider theme={{
          fontFamily: 'var(--font-ubuntu)',
          headings: { fontFamily: 'var(--font-ubuntu)' }
        }}>
          {children}
        </MantineProvider>
      </body>
    </html>
  );
}
