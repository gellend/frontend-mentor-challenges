import Sidebar from '@/components/layout/Sidebar';
import { Box, Paper } from '@mantine/core';

export default function FormLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <Box
      style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        backgroundColor: 'hsl(218, 100%, 97%)',
        padding: '20px',
      }}
    >
      <Paper
        shadow="md"
        p="md"
        radius="md"
        style={{
          display: 'flex',
          maxWidth: '940px',
          width: '100%',
          backgroundColor: 'white',
        }}
      >
        <Sidebar />
        <Box style={{ flex: 1, padding: '20px 40px' }}>
          {children}
        </Box>
      </Paper>
    </Box>
  );
} 