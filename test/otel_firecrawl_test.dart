// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_firecrawl/otel_firecrawl.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_firecrawl-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('scrape records formats + markdown length + credits', () async {
    await tracedFirecrawl<String>(
      operation: 'scrape',
      invoke: () async => const FirecrawlCallResult(
        value: 'ok',
        result: FirecrawlResult(
          url: 'https://example.com/article',
          formats: ['markdown', 'links'],
          onlyMainContent: true,
          markdownLength: 12500,
          linkCount: 42,
          creditsUsed: 1,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('firecrawl scrape')!);
    expect(a['firecrawl.markdown.length'], 12500);
    expect(a['firecrawl.credits.used'], 1);
  });

  test('crawl with failed status sets span error', () async {
    await tracedFirecrawl<String>(
      operation: 'crawlStatus',
      invoke: () async => const FirecrawlCallResult(
        value: 'ok',
        result: FirecrawlResult(
          jobId: 'cw_1',
          crawlStatus: 'failed',
          crawlPageLimit: 100,
          crawlPagesCrawled: 14,
        ),
      ),
    );
    expect(
      spans.findSpanByName('firecrawl crawlStatus')!.status,
      SpanStatusCode.Error,
    );
  });

  test('extract with schema flag', () async {
    await tracedFirecrawl<String>(
      operation: 'extract',
      invoke: () async => const FirecrawlCallResult(
        value: 'ok',
        result: FirecrawlResult(
          url: 'https://example.com',
          extractSchemaProvided: true,
          creditsUsed: 5,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('firecrawl extract')!);
    expect(a['firecrawl.extract.schema_provided'], true);
  });

  test('suppression skips spans', () async {
    await runWithoutFirecrawlInstrumentationAsync(() async {
      await tracedFirecrawl<String>(
        operation: 'mapUrl',
        invoke: () async => const FirecrawlCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('firecrawl '), isEmpty);
  });
}
