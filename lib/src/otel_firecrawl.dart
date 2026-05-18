// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_firecrawl_suppression.dart';

const _tracerName = 'dartastic_otel_libs_firecrawl';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class FirecrawlResult {
  const FirecrawlResult({
    this.url,
    this.jobId,
    this.formats,
    this.onlyMainContent,
    this.waitForMs,
    this.actions,
    this.actionCount,
    this.screenshot,
    this.markdownLength,
    this.htmlLength,
    this.linkCount,
    this.crawlPageLimit,
    this.crawlPagesCrawled,
    this.crawlStatus,
    this.creditsUsed,
    this.extractSchemaProvided,
    this.searchQuery,
    this.searchResultCount,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// Target URL (single-page) or root URL (crawl).
  final String? url;

  /// `cw_xxx` async job id.
  final String? jobId;

  /// `markdown`, `html`, `raw_html`, `links`, `screenshot`,
  /// `screenshot@fullPage`, `extract`, `json`.
  final List<String>? formats;

  final bool? onlyMainContent;

  final int? waitForMs;

  /// `wait`, `click`, `screenshot`, `write`, `press`, `scroll`,
  /// `scrape`, `executeJavascript`.
  final List<String>? actions;
  final int? actionCount;

  final bool? screenshot;

  final int? markdownLength;
  final int? htmlLength;

  final int? linkCount;

  // ── Crawl ──────────────────────────────────────────────────────
  final int? crawlPageLimit;
  final int? crawlPagesCrawled;

  /// `scraping`, `completed`, `cancelled`, `failed`, `paused`.
  final String? crawlStatus;

  /// Firecrawl credits charged (primary billing dimension).
  final int? creditsUsed;

  /// `/extract` schema was provided (structured extraction).
  final bool? extractSchemaProvided;

  // ── Search ────────────────────────────────────────────────────
  final String? searchQuery;
  final int? searchResultCount;

  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class FirecrawlCallResult<T> {
  const FirecrawlCallResult({required this.value, this.result});
  final T value;
  final FirecrawlResult? result;
}

/// Wraps a Firecrawl API call in a CLIENT span. [operation] is one of
/// `scrape`, `crawl`, `crawlStatus`, `crawlCancel`, `mapUrl`,
/// `batchScrape`, `batchScrapeStatus`, `extract`, `extractStatus`,
/// `search`, `deepResearch`, `generateLlmsText`.
Future<T> tracedFirecrawl<T>({
  required String operation,
  required Future<FirecrawlCallResult<T>> Function() invoke,
}) async {
  if (firecrawlInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'firecrawl',
    'rpc.method': operation,
    'firecrawl.operation': operation,
  };

  final span = _tracer().startSpan(
    'firecrawl $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.url != null) {
        extras.add(OTel.attributeString('firecrawl.url', res.url!));
      }
      if (res.jobId != null) {
        extras.add(OTel.attributeString('firecrawl.job.id', res.jobId!));
      }
      if (res.formats != null) {
        extras.add(OTel.attributeStringList(
          'firecrawl.formats',
          res.formats!,
        ));
      }
      if (res.onlyMainContent != null) {
        extras.add(OTel.attributeBool(
          'firecrawl.only_main_content',
          res.onlyMainContent!,
        ));
      }
      if (res.waitForMs != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.wait_for_ms',
          res.waitForMs!,
        ));
      }
      if (res.actions != null) {
        extras.add(OTel.attributeStringList(
          'firecrawl.actions',
          res.actions!,
        ));
      }
      if (res.actionCount != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.action.count',
          res.actionCount!,
        ));
      }
      if (res.screenshot != null) {
        extras.add(OTel.attributeBool(
          'firecrawl.screenshot',
          res.screenshot!,
        ));
      }
      if (res.markdownLength != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.markdown.length',
          res.markdownLength!,
        ));
      }
      if (res.htmlLength != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.html.length',
          res.htmlLength!,
        ));
      }
      if (res.linkCount != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.link.count',
          res.linkCount!,
        ));
      }
      if (res.crawlPageLimit != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.crawl.page_limit',
          res.crawlPageLimit!,
        ));
      }
      if (res.crawlPagesCrawled != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.crawl.pages_crawled',
          res.crawlPagesCrawled!,
        ));
      }
      if (res.crawlStatus != null) {
        extras.add(OTel.attributeString(
          'firecrawl.crawl.status',
          res.crawlStatus!,
        ));
        if (res.crawlStatus == 'failed') {
          span.setStatus(SpanStatusCode.Error, 'Firecrawl crawl failed');
        }
      }
      if (res.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.credits.used',
          res.creditsUsed!,
        ));
      }
      if (res.extractSchemaProvided != null) {
        extras.add(OTel.attributeBool(
          'firecrawl.extract.schema_provided',
          res.extractSchemaProvided!,
        ));
      }
      if (res.searchQuery != null) {
        extras.add(OTel.attributeString(
          'firecrawl.search.query',
          res.searchQuery!,
        ));
      }
      if (res.searchResultCount != null) {
        extras.add(OTel.attributeInt(
          'firecrawl.search.result_count',
          res.searchResultCount!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'firecrawl.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Firecrawl ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'firecrawl.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Firecrawl HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
