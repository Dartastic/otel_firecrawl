// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_firecrawl/otel_firecrawl.dart';

/// Traces Firecrawl calls with OpenTelemetry.
///
/// `otel_firecrawl` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Firecrawl call in
/// [tracedFirecrawl]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'firecrawl-example');

  // Wraps a Firecrawl API call in a CLIENT span.
  final firecrawlId = await tracedFirecrawl<String>(
    operation: 'create',
    invoke: () async {
      // Make the Firecrawl call here, then report what it returned.
      const id = 'firecrawl_8f3a2c';
      return const FirecrawlCallResult(
          value: id,
          result: FirecrawlResult(
              url: 'https://api.example.com/v1/resource',
              jobId: 'cw_3Mtw8f3a2c',
              formats: ['markdown'],
              onlyMainContent: true,
              waitForMs: 120,
              actions: ['wait'],
              actionCount: 3,
              screenshot: true,
              markdownLength: 1,
              htmlLength: 1,
              linkCount: 3,
              crawlPageLimit: 1,
              crawlPagesCrawled: 1,
              crawlStatus: 'scraping',
              creditsUsed: 1,
              extractSchemaProvided: true,
              searchQuery: 'example',
              searchResultCount: 3,
              errorCode: 'example',
              errorMessage: 'example',
              statusCode: 201));
    },
  );
  OTelLog.info('tracedFirecrawl create returned $firecrawlId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutFirecrawlInstrumentationAsync.
  await runWithoutFirecrawlInstrumentationAsync(
    () => tracedFirecrawl<String>(
      operation: 'create',
      invoke: () async {
        const id = 'firecrawl_8f3a2c';
        return const FirecrawlCallResult(
            value: id,
            result: FirecrawlResult(
                url: 'https://api.example.com/v1/resource',
                jobId: 'cw_3Mtw8f3a2c',
                formats: ['markdown'],
                onlyMainContent: true,
                waitForMs: 120,
                actions: ['wait'],
                actionCount: 3,
                screenshot: true,
                markdownLength: 1,
                htmlLength: 1,
                linkCount: 3,
                crawlPageLimit: 1,
                crawlPagesCrawled: 1,
                crawlStatus: 'scraping',
                creditsUsed: 1,
                extractSchemaProvided: true,
                searchQuery: 'example',
                searchResultCount: 3,
                errorCode: 'example',
                errorMessage: 'example',
                statusCode: 201));
      },
    ),
  );

  await OTel.shutdown();
}
