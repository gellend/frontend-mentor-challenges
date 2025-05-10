'use client'; // Required for components with event handlers or state, common for form elements

import { Box, Button, Stack, Text, TextInput, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { useRouter } from 'next/navigation'; // For navigation
import { useFormStore } from '@/store/formStore';
import { PersonalInfoData } from '@/types/form';
import { useEffect } from 'react';

export default function YourInfoStep() {
  const router = useRouter();
  const personalInfo = useFormStore((state) => state.personalInfo);
  const setPersonalInfo = useFormStore((state) => state.setPersonalInfo);
  const setCurrentStep = useFormStore((state) => state.setCurrentStep);

  const form = useForm<PersonalInfoData>({
    mode: 'uncontrolled', // Use 'uncontrolled' if you initialize with useEffect
    initialValues: personalInfo,
    validate: {
      name: (value) => (value.trim().length < 2 ? 'Name must have at least 2 letters' : null),
      email: (value) => (/^\S+@\S+$/.test(value) ? null : 'Invalid email'),
      phoneNumber: (value) =>
        value.trim().length < 7 ? 'Phone number is too short' : null, // Basic validation
    },
  });

  // Synchronize form with store if store changes (e.g., user navigates back and forth)
  useEffect(() => {
    form.setValues(personalInfo);
  }, [personalInfo]);


  const handleSubmit = (values: PersonalInfoData) => {
    setPersonalInfo(values);
    setCurrentStep(2); // Assuming this is step 1, next is step 2
    router.push('/form/select-plan'); // Navigate to the next step
  };

  return (
    <Box component="form" onSubmit={form.onSubmit(handleSubmit)}>
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
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
          {...form.getInputProps('name')}
        />
        <TextInput
          label="Email Address"
          placeholder="e.g. stephenking@lorem.com"
          type="email"
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
          {...form.getInputProps('email')}
        />
        <TextInput
          label="Phone Number"
          placeholder="e.g. +1 234 567 890"
          type="tel"
          styles={{
            label: { color: 'hsl(213, 96%, 18%)', fontWeight: 500 },
          }}
          {...form.getInputProps('phoneNumber')}
        />
      </Stack>

      <Box mt="xl" style={{ display: 'flex', justifyContent: 'flex-end' }}>
        <Button type="submit" style={{ backgroundColor: 'hsl(213, 96%, 18%)' }}>
          Next Step
        </Button>
      </Box>
    </Box>
  );
} 