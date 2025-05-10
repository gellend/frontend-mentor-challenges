'use client';

import { Container, Stack, Image, Title, Text, Center } from '@mantine/core';

export default function ThankYouPage() {
  return (
    <Center style={{ height: '100%' }}>
      <Container size="xs" style={{ textAlign: 'center' }}>
        <Stack align="center" gap="lg">
          <Image
            src="/assets/images/icon-thank-you.svg"
            alt="Thank you icon"
            w={80} // Adjusted width for a larger icon, similar to common designs
            h={80} // Adjusted height
          />
          <Title order={1} style={{ color: 'hsl(213, 96%, 18%)', fontWeight: 700 }}>
            Thank you!
          </Title>
          <Text size="lg" style={{ color: 'hsl(231, 11%, 63%)' }}>
            Thanks for confirming your subscription! We hope you have fun
            using our platform. If you ever need support, please feel free
            to email us at support@loremgaming.com.
          </Text>
        </Stack>
      </Container>
    </Center>
  );
} 