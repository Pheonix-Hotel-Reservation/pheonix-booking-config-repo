# OpenSearch Dashboards Visualization Suggestions

This document provides suggestions for creating useful dashboards and visualizations in OpenSearch Dashboards for the Phoenix Hotel Booking application.

## Index Patterns to Create

First, create these index patterns in OpenSearch Dashboards:

1. **phoenix-*** - Pattern: `phoenix-*` (covers all service-specific indices)
2. **kubernetes-logs** - Pattern: `kubernetes-logs-*`
3. **All Logs** - Pattern: `phoenix-*,kubernetes-logs-*`

## Dashboard 1: Application Overview Dashboard

### Visualizations:

#### 1. Log Volume Over Time (Area Chart)
- **Purpose**: Monitor overall log volume trends
- **Index Pattern**: `phoenix-*`
- **X-Axis**: `@timestamp` (Date Histogram, 15m interval)
- **Y-Axis**: Count
- **Split Series**: `kubernetes.labels.app` (Terms aggregation)
- **Use Case**: Identify which services generate the most logs and detect anomalies

#### 2. Service Log Distribution (Pie Chart)
- **Purpose**: See log distribution across services
- **Index Pattern**: `phoenix-*`
- **Slice By**: `kubernetes.labels.app` (Terms aggregation, Top 10)
- **Use Case**: Quick overview of service activity

#### 3. Error Rate by Service (Vertical Bar Chart)
- **Purpose**: Track error rates per service
- **Index Pattern**: `phoenix-*`
- **X-Axis**: `kubernetes.labels.app` (Terms aggregation)
- **Y-Axis**: Count
- **Filter**: `log: *error* OR log: *Error* OR log: *ERROR* OR log: *exception* OR log: *Exception* OR log: *fail* OR log: *Fail*`
- **Use Case**: Identify services with high error rates

#### 4. HTTP Status Codes (Data Table)
- **Purpose**: Monitor API response status codes
- **Index Pattern**: `phoenix-*`
- **Columns**: 
  - `kubernetes.labels.app`
  - HTTP status code (extracted from log message if available)
  - Count
- **Use Case**: Track API health and identify 4xx/5xx errors

#### 5. Top Error Messages (Data Table)
- **Purpose**: Most frequent error messages
- **Index Pattern**: `phoenix-*`
- **Filter**: `log: *error* OR log: *Error* OR log: *ERROR*`
- **Columns**: 
  - Error message (extracted from log)
  - Count
  - Service (`kubernetes.labels.app`)
- **Use Case**: Identify recurring issues

#### 6. Pod Restart Events (Timeline)
- **Purpose**: Track pod restarts
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `log: *Started container* OR log: *Container started*`
- **X-Axis**: `@timestamp`
- **Y-Axis**: `kubernetes.pod_name`
- **Use Case**: Monitor pod stability

## Dashboard 2: Service-Specific Dashboard

### Visualizations (repeat for each service):

#### 1. Service Log Volume (Line Chart)
- **Purpose**: Monitor individual service log volume
- **Index Pattern**: `phoenix-{service-name}-*` (e.g., `phoenix-user-service-*`)
- **X-Axis**: `@timestamp` (Date Histogram, 5m interval)
- **Y-Axis**: Count
- **Use Case**: Detect traffic spikes or service degradation

#### 2. Log Level Distribution (Pie Chart)
- **Purpose**: See log level breakdown
- **Index Pattern**: `phoenix-{service-name}-*`
- **Slice By**: Log level (if structured logging with `level` field, or extract from message)
- **Filter**: Extract level from JSON message if available
- **Use Case**: Understand logging patterns (INFO vs ERROR vs DEBUG)

#### 3. Namespace Distribution (Horizontal Bar Chart)
- **Purpose**: See which namespaces the service runs in
- **Index Pattern**: `phoenix-{service-name}-*`
- **X-Axis**: Count
- **Y-Axis**: `kubernetes.namespace_name`
- **Use Case**: Monitor multi-environment deployments (staging vs production)

#### 4. Pod Activity Heatmap
- **Purpose**: Visualize pod activity patterns
- **Index Pattern**: `phoenix-{service-name}-*`
- **X-Axis**: `@timestamp` (Date Histogram, 1h interval)
- **Y-Axis**: `kubernetes.pod_name`
- **Color**: Count of logs
- **Use Case**: Identify which pods are most active

## Dashboard 3: Error & Alerting Dashboard

### Visualizations:

#### 1. Error Trend Over Time (Line Chart)
- **Purpose**: Track error trends
- **Index Pattern**: `phoenix-*`
- **X-Axis**: `@timestamp` (Date Histogram, 15m interval)
- **Y-Axis**: Count
- **Filter**: `log: *error* OR log: *Error* OR log: *ERROR* OR log: *exception* OR log: *Exception*`
- **Split Series**: `kubernetes.labels.app`
- **Use Case**: Detect error spikes and trends

#### 2. Critical Errors (Data Table)
- **Purpose**: List critical errors requiring attention
- **Index Pattern**: `phoenix-*`
- **Filter**: `log: *FATAL* OR log: *CRITICAL* OR log: *panic*`
- **Columns**:
  - `@timestamp`
  - `kubernetes.labels.app`
  - `kubernetes.pod_name`
  - `log` (message)
- **Sort**: `@timestamp` (descending)
- **Use Case**: Immediate attention items

#### 3. Error Rate by Hour (Vertical Bar Chart)
- **Purpose**: Identify peak error hours
- **Index Pattern**: `phoenix-*`
- **X-Axis**: Hour of day (extracted from `@timestamp`)
- **Y-Axis**: Count
- **Filter**: `log: *error* OR log: *Error* OR log: *ERROR*`
- **Use Case**: Identify patterns (e.g., errors spike during peak hours)

#### 4. Service Health Score (Metric)
- **Purpose**: Overall health indicator
- **Formula**: `(Total Logs - Error Logs) / Total Logs * 100`
- **Index Pattern**: `phoenix-*`
- **Use Case**: Quick health check

## Dashboard 4: Performance & Operations Dashboard

### Visualizations:

#### 1. Request Latency Distribution (Histogram)
- **Purpose**: Monitor API response times
- **Index Pattern**: `phoenix-*`
- **X-Axis**: Response time (if logged, extract from message)
- **Y-Axis**: Count
- **Use Case**: Identify slow endpoints

#### 2. Log Volume by Namespace (Stacked Area Chart)
- **Purpose**: Compare staging vs production
- **Index Pattern**: `phoenix-*`
- **X-Axis**: `@timestamp` (Date Histogram)
- **Y-Axis**: Count
- **Split Series**: `kubernetes.namespace_name`
- **Use Case**: Compare environments

#### 3. Container Logs (Data Table)
- **Purpose**: View recent logs with context
- **Index Pattern**: `phoenix-*`
- **Columns**:
  - `@timestamp`
  - `kubernetes.labels.app`
  - `kubernetes.pod_name`
  - `kubernetes.namespace_name`
  - `log`
- **Sort**: `@timestamp` (descending)
- **Use Case**: Log exploration and debugging

#### 4. Unique Pods Over Time (Line Chart)
- **Purpose**: Track pod count changes
- **Index Pattern**: `phoenix-*`
- **X-Axis**: `@timestamp` (Date Histogram, 1h interval)
- **Y-Axis**: Unique count of `kubernetes.pod_name`
- **Split Series**: `kubernetes.labels.app`
- **Use Case**: Monitor scaling events

## Dashboard 5: Business Metrics Dashboard

### Visualizations:

#### 1. Reservation Service Activity (Line Chart)
- **Purpose**: Track booking activity
- **Index Pattern**: `phoenix-reservation-service-*`
- **X-Axis**: `@timestamp` (Date Histogram, 1h interval)
- **Y-Axis**: Count
- **Filter**: Extract reservation events from logs (e.g., `log: *reservation* OR log: *booking*`)
- **Use Case**: Business metrics and peak hours

#### 2. Search Query Trends (Data Table)
- **Purpose**: Most common search queries
- **Index Pattern**: `phoenix-search-service-*`
- **Filter**: Extract search queries from logs
- **Columns**: Search term, Count
- **Use Case**: Understand user behavior

#### 3. User Activity by Service (Stacked Bar Chart)
- **Purpose**: Track user interactions
- **Index Pattern**: `phoenix-user-service-*`
- **X-Axis**: `@timestamp` (Date Histogram, 1h interval)
- **Y-Axis**: Count
- **Filter**: Extract user actions (login, signup, profile updates)
- **Use Case**: User engagement metrics

## Dashboard 6: Infrastructure & Platform Errors Dashboard

This dashboard focuses on infrastructure-level errors from platform components (Prometheus, OpenSearch, Vault, Istio, etc.)

### Visualizations:

#### 1. Infrastructure I/O Errors (Data Table)
- **Purpose**: Track I/O errors from infrastructure components
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `message: *"input/output error"* OR message: *"I/O error"* OR message: *"io error"* OR message: *"write to WAL"* OR message: *"WAL"*`
- **Columns**:
  - `@timestamp`
  - `kubernetes.labels.app` or `kubernetes.container_name`
  - `kubernetes.pod_name`
  - `kubernetes.namespace_name`
  - `message` (truncated to 200 chars)
- **Sort**: `@timestamp` (descending)
- **Use Case**: Critical infrastructure issues requiring immediate attention

#### 2. Prometheus WAL Errors (Timeline)
- **Purpose**: Track Prometheus Write-Ahead Log errors
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `kubernetes.container_name: prometheus AND (message: *"WAL"* OR message: *"write to WAL"* OR message: *"Rule sample appending failed"*)`
- **X-Axis**: `@timestamp` (Date Histogram, 5m interval)
- **Y-Axis**: `kubernetes.pod_name`
- **Color**: Count of errors
- **Use Case**: Monitor Prometheus storage health

#### 3. Infrastructure Error Types (Pie Chart)
- **Purpose**: Categorize infrastructure errors
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `message: *"error"* OR message: *"Error"* OR message: *"ERROR"* OR message: *"failed"* OR message: *"Failed"*`
- **Slice By**: Error type (extracted using regex or runtime field):
  - I/O errors: `*"input/output error"* OR *"I/O error"* OR *"io error"*`
  - WAL errors: `*"WAL"* OR *"write to WAL"*`
  - Storage errors: `*"storage"* AND *"error"*`
  - Network errors: `*"network"* AND *"error"*`
  - Other errors
- **Use Case**: Understand infrastructure error patterns

#### 4. Platform Component Health (Metric)
- **Purpose**: Overall platform health indicator
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system) AND (message: *"error"* OR message: *"Error"* OR message: *"ERROR"* OR message: *"failed"* OR message: *"Failed"*)`
- **Metric**: Count of errors in last hour
- **Use Case**: Quick platform health check

#### 5. Infrastructure Error Rate Over Time (Line Chart)
- **Purpose**: Track infrastructure error trends
- **Index Pattern**: `kubernetes-logs-*`
- **X-Axis**: `@timestamp` (Date Histogram, 15m interval)
- **Y-Axis**: Count
- **Filter**: `message: *"error"* OR message: *"Error"* OR message: *"ERROR"* OR message: *"failed"* OR message: *"Failed"*`
- **Split Series**: `kubernetes.namespace_name` (filtered to: monitoring, opensearch, vault, istio-system)
- **Use Case**: Detect infrastructure degradation

#### 6. Critical Infrastructure Errors (Data Table)
- **Purpose**: List critical infrastructure errors
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `(message: *"input/output error"* OR message: *"WAL"* OR message: *"panic"* OR message: *"FATAL"* OR message: *"CRITICAL"*) AND kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system)`
- **Columns**:
  - `@timestamp`
  - `kubernetes.namespace_name`
  - `kubernetes.container_name`
  - `kubernetes.pod_name`
  - `message` (full message)
- **Sort**: `@timestamp` (descending)
- **Limit**: Top 50
- **Use Case**: Immediate attention items

#### 7. Storage Errors by Component (Vertical Bar Chart)
- **Purpose**: Identify components with storage issues
- **Index Pattern**: `kubernetes-logs-*`
- **X-Axis**: `kubernetes.container_name` or `kubernetes.labels.app`
- **Y-Axis**: Count
- **Filter**: `message: *"input/output error"* OR message: *"I/O error"* OR message: *"storage"* AND *"error"* OR message: *"WAL"*`
- **Use Case**: Identify components with persistent storage issues

#### 8. Log Level Distribution - Infrastructure (Pie Chart)
- **Purpose**: See log level breakdown for infrastructure components
- **Index Pattern**: `kubernetes-logs-*`
- **Filter**: `kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system)`
- **Slice By**: Extract log level from message:
  - Extract `level=WARN`, `level=ERROR`, `level=INFO`, etc. from structured logs
  - Or use pattern matching: `message: *"level=WARN"*`, `message: *"level=ERROR"*`
- **Use Case**: Understand infrastructure logging patterns

### Parsing Structured Log Fields

For logs with structured format like `time=... level=WARN source=... msg=...`, create runtime fields:

#### Runtime Field: `log_level`
- **Type**: Keyword
- **Script** (Painless):
```painless
if (doc['message.keyword'].size() > 0) {
    String msg = doc['message.keyword'].value;
    if (msg.contains('level=ERROR') || msg.contains('level=error')) {
        return 'ERROR';
    } else if (msg.contains('level=WARN') || msg.contains('level=warn')) {
        return 'WARN';
    } else if (msg.contains('level=INFO') || msg.contains('level=info')) {
        return 'INFO';
    } else if (msg.contains('level=DEBUG') || msg.contains('level=debug')) {
        return 'DEBUG';
    }
}
return 'UNKNOWN';
```

#### Runtime Field: `error_type`
- **Type**: Keyword
- **Script** (Painless):
```painless
if (doc['message.keyword'].size() > 0) {
    String msg = doc['message.keyword'].value;
    if (msg.contains('input/output error') || msg.contains('I/O error') || msg.contains('io error')) {
        return 'IO_ERROR';
    } else if (msg.contains('WAL') || msg.contains('write to WAL')) {
        return 'WAL_ERROR';
    } else if (msg.contains('storage') && msg.contains('error')) {
        return 'STORAGE_ERROR';
    } else if (msg.contains('network') && msg.contains('error')) {
        return 'NETWORK_ERROR';
    }
}
return 'OTHER';
```

### Saved Searches for Infrastructure Errors

1. **Prometheus WAL Errors**: 
   ```
   kubernetes.container_name: prometheus AND (message: *"WAL"* OR message: *"write to WAL"* OR message: *"Rule sample appending failed"*)
   ```

2. **All I/O Errors**: 
   ```
   message: *"input/output error"* OR message: *"I/O error"* OR message: *"io error"*
   ```

3. **Infrastructure Errors**: 
   ```
   kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system) AND (message: *"error"* OR message: *"Error"* OR message: *"ERROR"*)
   ```

4. **Storage Issues**: 
   ```
   message: *"input/output error"* OR message: *"storage"* AND *"error"* OR message: *"WAL"* OR message: *"disk"* AND *"error"*
   ```

5. **Prometheus Errors**: 
   ```
   kubernetes.container_name: prometheus AND (message: *"error"* OR message: *"Error"* OR message: *"ERROR"* OR message: *"failed"*)
   ```

### Alerting for Infrastructure Errors

Set up critical alerts:

1. **Prometheus WAL Errors**: Alert if any WAL error occurs (immediate)
2. **I/O Errors**: Alert if > 3 I/O errors in 5 minutes
3. **Storage Errors**: Alert if any storage error in infrastructure components
4. **Infrastructure Component Down**: No logs from Prometheus/OpenSearch/Vault for 5 minutes
5. **Error Rate Spike**: Infrastructure error rate increases by 300% in 10 minutes

### Example DQL Queries for Infrastructure Errors

#### Find Prometheus WAL errors:
```
kubernetes.container_name: prometheus AND (message: *"WAL"* OR message: *"write to WAL"* OR message: *"Rule sample appending failed"*)
```

#### Find all I/O errors:
```
message: *"input/output error"* OR message: *"I/O error"* OR message: *"io error"*
```

#### Find infrastructure errors by namespace:
```
kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system) AND (message: *"error"* OR message: *"Error"* OR message: *"ERROR"*)
```

#### Find Prometheus errors with level extraction:
```
kubernetes.container_name: prometheus AND message: *"level=ERROR"* OR message: *"level=WARN"*
```

#### Count I/O errors by component:
```
(message: *"input/output error"* OR message: *"I/O error"*) | stats count() by kubernetes.container_name
```

## Advanced Visualizations

### 1. Log Level Heatmap by Service
- **Purpose**: Visualize log levels across services
- **Type**: Heatmap
- **X-Axis**: `kubernetes.labels.app`
- **Y-Axis**: Log level (INFO, WARN, ERROR, DEBUG)
- **Color**: Count
- **Use Case**: Quick overview of service health

### 2. Error Correlation Matrix
- **Purpose**: Find services with correlated errors
- **Type**: Matrix
- **Rows/Columns**: `kubernetes.labels.app`
- **Value**: Error count correlation
- **Use Case**: Identify cascading failures

### 3. Geographic Distribution (if IP addresses are logged)
- **Purpose**: See request origins
- **Type**: Map visualization
- **Field**: Source IP (if available in logs)
- **Use Case**: Understand user distribution

## Saved Searches

Create these saved searches for quick access:

### Application Errors:
1. **All Errors**: `log: *error* OR log: *Error* OR log: *ERROR* OR log: *exception*`
2. **Reservation Service Errors**: `kubernetes.labels.app: reservation-service AND (log: *error* OR log: *Error*)`
3. **Production Only**: `kubernetes.namespace_name: phoenix-production`
4. **Staging Only**: `kubernetes.namespace_name: phoenix-staging`
5. **Recent Critical**: `log: *FATAL* OR log: *CRITICAL* OR log: *panic*`
6. **Pod Restarts**: `log: *Started container*`

### Infrastructure Errors:
7. **Prometheus WAL Errors**: `kubernetes.container_name: prometheus AND (message: *"WAL"* OR message: *"write to WAL"* OR message: *"Rule sample appending failed"*)`
8. **All I/O Errors**: `message: *"input/output error"* OR message: *"I/O error"* OR message: *"io error"*`
9. **Infrastructure Errors**: `kubernetes.namespace_name: (monitoring OR opensearch OR vault OR istio-system) AND (message: *"error"* OR message: *"Error"* OR message: *"ERROR"*)`
10. **Storage Issues**: `message: *"input/output error"* OR message: *"storage"* AND *"error"* OR message: *"WAL"* OR message: *"disk"* AND *"error"*`

## Alerting Suggestions

Set up alerts for:

### Application Alerts:
1. **High Error Rate**: Error count > 100 in 5 minutes
2. **Service Down**: No logs from a service for 10 minutes
3. **Critical Errors**: Any FATAL or CRITICAL level logs
4. **Pod Restart Spike**: > 5 pod restarts in 15 minutes
5. **Log Volume Spike**: Log volume increases by 200% in 10 minutes

### Infrastructure Alerts:
6. **Prometheus WAL Errors**: Alert immediately if any WAL error occurs
7. **I/O Errors**: Alert if > 3 I/O errors in 5 minutes from any infrastructure component
8. **Storage Errors**: Alert if any storage error in Prometheus, OpenSearch, or Vault
9. **Infrastructure Component Down**: No logs from Prometheus/OpenSearch/Vault for 5 minutes
10. **Infrastructure Error Rate Spike**: Infrastructure error rate increases by 300% in 10 minutes

## Tips for Implementation

1. **Use Runtime Fields**: If your logs contain JSON in the `log` field, create runtime fields to extract structured data:
   - `level` from `message.level`
   - `statusCode` from `message.statusCode`
   - `duration` from `message.duration`

2. **Create Index Templates**: Ensure consistent field mappings across indices

3. **Use Scripted Fields**: For complex extractions, use scripted fields in OpenSearch Dashboards

4. **Refresh Intervals**: Set appropriate refresh intervals (15s for real-time, 1m for overview dashboards)

5. **Time Ranges**: Create saved time ranges:
   - Last 15 minutes
   - Last hour
   - Last 24 hours
   - Last 7 days

6. **Dashboard Links**: Link dashboards together for navigation (e.g., click on a service name to drill down)

## Example DQL Queries

### Find all errors in the last hour:
```
kubernetes.labels.app: * AND (log: *error* OR log: *Error* OR log: *ERROR*)
```

### Find reservation service errors:
```
kubernetes.labels.app: reservation-service AND (log: *error* OR log: *Error*)
```

### Find logs from production namespace:
```
kubernetes.namespace_name: phoenix-production
```

### Find specific pod logs:
```
kubernetes.pod_name: user-service-* AND @timestamp: [now-1h TO now]
```

### Count logs by service:
```
kubernetes.labels.app: * | stats count() by kubernetes.labels.app
```

### Find Prometheus WAL I/O errors (specific example):
```
kubernetes.container_name: prometheus AND message: *"write to WAL"* AND message: *"input/output error"*
```

### Find Prometheus rule sample errors:
```
kubernetes.container_name: prometheus AND message: *"Rule sample appending failed"*
```

### Extract structured fields from Prometheus logs:
For logs like `level=WARN source=group.go:569 msg="Rule sample appending failed"`, use:
```
kubernetes.container_name: prometheus AND message: *"level=WARN"* AND message: *"Rule sample"*
```

## Quick Reference: Infrastructure Error Patterns

### Common Error Patterns to Monitor:

1. **Prometheus WAL Errors**:
   - Pattern: `*"write to WAL"*` AND `*"input/output error"*`
   - Indicates: Storage issues with Prometheus Write-Ahead Log
   - Action: Check Prometheus PVC, disk space, EBS volume health

2. **I/O Errors**:
   - Pattern: `*"input/output error"*` OR `*"I/O error"*` OR `*"io error"*`
   - Indicates: Disk/storage problems
   - Action: Check PVC status, EBS volumes, node disk health

3. **Storage Errors**:
   - Pattern: `*"storage"*` AND `*"error"*`
   - Indicates: Storage subsystem issues
   - Action: Review storage class, PVC bindings, volume attachments

4. **Network Errors**:
   - Pattern: `*"network"*` AND `*"error"*` OR `*"connection"*` AND `*"refused"*`
   - Indicates: Network connectivity issues
   - Action: Check service endpoints, network policies, DNS

5. **Component Failures**:
   - Pattern: `*"panic"*` OR `*"FATAL"*` OR `*"CRITICAL"*`
   - Indicates: Critical component failures
   - Action: Immediate investigation required

These visualizations will help you monitor, debug, and optimize your Phoenix Hotel Booking application effectively!

