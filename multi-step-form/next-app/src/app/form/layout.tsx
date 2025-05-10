'use client';

import Sidebar from '@/components/layout/Sidebar';
import { Box, Paper } from '@mantine/core';
import { useMediaQuery } from '@mantine/hooks';

export default function FormLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const isMobile = useMediaQuery('(max-width: 768px)');

  return (
    <Box
      style={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: isMobile ? 'flex-start' : 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: 'hsl(218, 100%, 97%)',
        padding: isMobile ? '0' : '20px',
      }}
    >
      {isMobile && <Sidebar />}
      <Paper
        shadow={isMobile ? "none" : "md"}
        p={isMobile ? "xl" : "md"}
        radius={isMobile ? "md" : "md"}
        style={{
          display: 'flex',
          flexDirection: isMobile ? 'column' : 'row',
          width: isMobile ? 'calc(100% - 40px)' : '100%',
          maxWidth: isMobile ? '500px' : '940px',
          backgroundColor: 'white',
          marginTop: isMobile ? '-70px' : '0',
          zIndex: 1,
          position: 'relative',
        }}
      >
        {!isMobile && <Sidebar />}
        <Box style={{ flex: 1, padding: isMobile ? '20px 0px' : '20px 40px' }}>
          {children}
        </Box>
      </Paper>
    </Box>
  );
} 