'use client'; // Required for components with event handlers or state, common for form elements

import { Box, Button, Stack, Text, TextInput, Title } from '@mantine/core';

export default function YourInfoStep() {
  return (
    <Box>
      <Title order={2} mb="xs" style={{ color: 'hsl(213, 96%, 18%)', fontWeight: 700 }}>
        Personal info
      </Title>
      <Text mb="lg" style={{ color: 'hsl(231, 11%, 63%)' }}>
        Please provide your name, email address, and phone number.
      </Text>

      <Stack gap="md">
        <TextInput
          label="Name"
          placeholder="e.g. Stephen King"
          // TODO: Add form handling (e.g., form.getInputProps('name'))
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
        />
        <TextInput
          label="Email Address"
          placeholder="e.g. stephenking@lorem.com"
          type="email"
          // TODO: Add form handling
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
        />
        <TextInput
          label="Phone Number"
          placeholder="e.g. +1 234 567 890"
          type="tel"
          // TODO: Add form handling
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
        />
      </Stack>

      <Box mt="xl" style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <Button
          style={{ backgroundColor: 'hsl(213, 96%, 18%)' }}
          // TODO: Add onClick handler for navigation
        >
          Next Step
        </Button>
      </Box>
    </Box>
  );
} 