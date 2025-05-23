'use client';

import { Box, Button, Group, Paper, Stack, Switch, Text, Title, UnstyledButton } from '@mantine/core';
import { useForm } from '@mantine/form';
import { useRouter } from 'next/navigation';
import { useFormStore } from '@/store/formStore';
// import { PlanData } from '@/types/form'; // Removed unused import
import { useEffect } from 'react'; // Removed unused useState
import classes from '@/styles/SelectPlanStep.module.css';
import { useMediaQuery } from '@mantine/hooks'; // Ensure this is imported
import Image from 'next/image'; // Import next/image

// Define plan details
const PLANS = [
  { id: 'arcade', name: 'Arcade', priceMonthly: 9, priceYearly: 90, icon: '/assets/images/icon-arcade.svg' },
  { id: 'advanced', name: 'Advanced', priceMonthly: 12, priceYearly: 120, icon: '/assets/images/icon-advanced.svg' },
  { id: 'pro', name: 'Pro', priceMonthly: 15, priceYearly: 150, icon: '/assets/images/icon-pro.svg' },
] as const;

type PlanId = typeof PLANS[number]['id'];

interface PlanFormValues {
  type: PlanId | null;
  billing: 'monthly' | 'yearly';
}

export default function SelectPlanStep() {
  const router = useRouter();
  // Corrected Zustand selectors
  const currentPlan = useFormStore((state) => state.plan);
  const setPlan = useFormStore((state) => state.setPlan);
  const setCurrentStep = useFormStore((state) => state.setCurrentStep);
  const isMobile = useMediaQuery('(max-width: 768px)'); // Correctly initialize isMobile

  const form = useForm<PlanFormValues>({
    initialValues: {
      type: currentPlan.type as PlanId || null,
      billing: currentPlan.billing || 'monthly',
    },
    validate: {
      type: (value) => (value === null ? 'Please select a plan' : null),
    },
  });

  useEffect(() => {
    if (currentPlan.type !== form.values.type || currentPlan.billing !== form.values.billing) {
        form.setValues({
            type: currentPlan.type as PlanId || null,
            billing: currentPlan.billing || 'monthly',
        });
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentPlan]); // form.setValues was removed as per previous successful edit, keeping it that way

  const handleSubmit = (values: PlanFormValues) => {
    const selectedPlanDetails = PLANS.find(p => p.id === values.type);
    if (selectedPlanDetails) {
      const price = values.billing === 'yearly' ? selectedPlanDetails.priceYearly : selectedPlanDetails.priceMonthly;
      setPlan({
        type: values.type,
        billing: values.billing,
        price: price,
      });
      setCurrentStep(3);
      router.push('/form/add-ons');
    }
  };

  const selectedBilling = form.values.billing;

  // Moved planCards mapping outside the return for clarity and to use isMobile
  const planCards = PLANS.map((planOption) => (
    <UnstyledButton
      key={planOption.id}
      onClick={() => form.setFieldValue('type', planOption.id)}
      className={classes.planCard}
      data-active={form.values.type === planOption.id || undefined}
      style={{
        ...(isMobile ? { width: '100%' } : { flex: 1 }),
      }}
    >
      <Image 
        src={planOption.icon} 
        alt={`${planOption.name} icon`} 
        className={classes.planIcon} 
        width={40} // Placeholder width
        height={40} // Placeholder height
      />
      <Box mt={isMobile ? 0 : 'auto'} style={{ flexGrow: 1, textAlign: 'left'}} >
        <Text fw={500} style={{ color: 'hsl(213, 96%, 18%)' }}>{planOption.name}</Text>
        <Text size="sm" style={{ color: 'hsl(231, 11%, 63%)' }}>
          ${selectedBilling === 'yearly' ? `${planOption.priceYearly}/yr` : `${planOption.priceMonthly}/mo`}
        </Text>
        {selectedBilling === 'yearly' && (
          <Text size="xs" style={{ color: 'hsl(213, 96%, 18%)' }}>2 months free</Text>
        )}
      </Box>
    </UnstyledButton>
  ));

  return (
    <Box component="form" onSubmit={form.onSubmit(handleSubmit)}>
      <Title order={2} mb="xs" style={{ color: 'hsl(213, 96%, 18%)', fontWeight: 700 }}>
        Select your plan
      </Title>
      <Text mb="lg" style={{ color: 'hsl(231, 11%, 63%)' }}>
        You have the option of monthly or yearly billing.
      </Text>

      {/* Conditional rendering of Stack or Group based on isMobile */}
      <Stack gap="md">
        {isMobile ? (
          <Stack gap="md">
            {planCards}
          </Stack>
        ) : (
          <Group grow gap="md" style={{ width: '100%' }}>
            {planCards}
          </Group>
        )}
        {form.errors.type && (
          <Text size="xs" color="red" mt="xs">{form.errors.type}</Text>
        )}
      </Stack>

      {/* Switch for monthly/yearly billing */}
      <Paper mt="xl" p="md" radius="md" withBorder style={{ backgroundColor: 'hsl(218, 100%, 97%)' }}>
        <Group justify="center" align="center">
          <Text fw={500} c={selectedBilling === 'monthly' ? 'hsl(213, 96%, 18%)' : 'hsl(231, 11%, 63%)'}>
            Monthly
          </Text>
          <Switch
            size="md"
            checked={selectedBilling === 'yearly'}
            onChange={(event) => form.setFieldValue('billing', event.currentTarget.checked ? 'yearly' : 'monthly')}
            aria-label="Billing cycle toggle"
          />
          <Text fw={500} c={selectedBilling === 'yearly' ? 'hsl(213, 96%, 18%)' : 'hsl(231, 11%, 63%)'}>
            Yearly
          </Text>
        </Group>
      </Paper>

      {/* Navigation buttons */}
      <Group justify="space-between" mt="xl">
        <Button variant="subtle" onClick={() => router.push('/form/your-info')}>
          Go Back
        </Button>
        <Button type="submit" style={{ backgroundColor: 'hsl(213, 96%, 18%)' }}>
          Next Step
        </Button>
      </Group>
    </Box>
  );
} 