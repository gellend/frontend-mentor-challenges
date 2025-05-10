'use client';

import { Box, Stack, Text, ThemeIcon } from '@mantine/core';
import { usePathname } from 'next/navigation';

interface Step {
  id: string;
  number: number;
  title: string;
  path: string;
}

const STEPS_DATA: Step[] = [
  { id: 'your-info', number: 1, title: 'YOUR INFO', path: '/form/your-info' },
  { id: 'select-plan', number: 2, title: 'SELECT PLAN', path: '/form/select-plan' },
  { id: 'add-ons', number: 3, title: 'ADD-ONS', path: '/form/add-ons' },
  { id: 'summary', number: 4, title: 'SUMMARY', path: '/form/summary' },
];

export default function Sidebar() {
  const currentStepId = usePathname().split('/').pop() || 'your-info';
  const currentStepNumber = STEPS_DATA.find(step => step.id === currentStepId)?.number || 1;

  return (
    <Box
      style={{
        width: '270px',
        minHeight: '500px',
        padding: '30px',
        backgroundImage: 'url(/assets/images/bg-sidebar-desktop.svg)',
        backgroundRepeat: 'no-repeat',
        backgroundSize: 'cover',
        backgroundPosition: 'center',
        borderRadius: '10px',
        marginRight: '20px',
      }}
    >
      <Stack gap="lg">
        {STEPS_DATA.map((step) => (
          <Box key={step.id} style={{ display: 'flex', alignItems: 'center' }}>
            <ThemeIcon
              variant={currentStepNumber === step.number ? 'filled' : 'outline'}
              radius="xl"
              size="lg"
              color={currentStepNumber === step.number ? 'hsl(206, 94%, 87%)' : 'white'}
              style={{
                border: currentStepNumber !== step.number ? '1px solid white' : 'none',
                color: currentStepNumber === step.number ? 'hsl(213, 96%, 18%)' : 'white',
                marginRight: '15px',
              }}
            >
              {step.number}
            </ThemeIcon>
            <Box>
              <Text size="xs" style={{ color: 'hsl(229, 24%, 87%)' }}>
                STEP {step.number}
              </Text>
              <Text fw={700} style={{ color: 'white' }}>
                {step.title}
              </Text>
            </Box>
          </Box>
        ))}
      </Stack>
    </Box>
  );
} 